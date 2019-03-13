//
//  OutstandingOrderViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/7/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

class OutstandingOrderViewModel {
    private let apiURLRequestFactory = APIURLRequestFactory()
    
    // MARK: - Dependencies
    var httpClient: HTTPClient
    var keyValueStore: KeyValueStore
    
    // MARK: - Section Model Properties
    private var constructedItemsTableViewSectionModel: UITableViewSectionModel? {
        didSet { tableViewSectionModels.value = makeTableViewSectionModels() }
    }
    
    // MARK: - View Settable Properties
    /// The bag's outstanding order's ID.
    /// Calling `beginDownloads()` will first attempt to get one if not set.
    var outstandingOrderID: OutstandingOrder.ID?
    
    var constructedItemStackCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]()
    var errorHandler: ((Error) -> Void)?
    
    // MARK: - Dynamic Properties
    let tableViewSectionModels = Dynamic([UITableViewSectionModel]())
    let isOutstandingOrderDownloading = Dynamic(false)
    let isItemsDownloading = Dynamic(false)
    
    private struct Constants {
        static let constructedItemStackCellViewModelHeight: Double = 100
    }
    
    init(httpClient: HTTPClient = URLSession.shared,
         keyValueStore: KeyValueStore = UserDefaults.standard) {
        self.httpClient = httpClient
        self.keyValueStore = keyValueStore
    }
    
    // MARK: - Download Methods
    func beginDownloads() {
        let outstandingOrderPromise: Promise<Void>
        if outstandingOrderID == nil {
            if let idString = keyValueStore.value(of: String.self, forKey: KeyValueStoreKeys.outstandingOrder),
                let id = OutstandingOrder.ID(uuidString: idString) {
                outstandingOrderID = id
                outstandingOrderPromise = beginOutstandingOrderDownload()
            } else { errorHandler?(OutstandingOrderViewModelError.noOutstandingOrders); return }
        } else {
            outstandingOrderPromise = beginOutstandingOrderDownload()
        }
        outstandingOrderPromise.catch { self.errorHandler?($0) }
    }
    
    func beginUpdateConstructedItemQuantityDownload(constructedItemID: ConstructedItem.ID, quantity: Int) {
        let quantityUpdatePromise: Promise<Void>
        if quantity > 0 {
            quantityUpdatePromise = partiallyUpdateOutstandingOrderConstructedItem(constructedItemID: constructedItemID, data: .init(quantity: quantity)).asVoid()
        } else {
            quantityUpdatePromise = removeOutstandingOrderConstructedItem(outstandingOrderID: outstandingOrderID ?? preconditionFailure(), constructedItemID: constructedItemID).asVoid()
        }
        quantityUpdatePromise.then { self.getOutstandingOrderConstructedItems() }
            .done { self.constructedItemsTableViewSectionModel = self.makeConstructedItemsTableViewSectionModel(constructedItems: $0) }
            .catch { self.errorHandler?($0) }
    }
    
    private func beginOutstandingOrderDownload() -> Promise<Void> {
        return getOutstandingOrder().done { self.outstandingOrderID = $0.id }
            .then { self.beginOutstandingOrderConstructedItemsDownload() }
    }
    
    private func beginOutstandingOrderConstructedItemsDownload() -> Promise<Void> {
        isItemsDownloading.value = true
        return getOutstandingOrderConstructedItems()
            .done { self.constructedItemsTableViewSectionModel = self.makeConstructedItemsTableViewSectionModel(constructedItems: $0) }
            .ensure { self.isItemsDownloading.value = false }
    }
    
    private func getOutstandingOrder() -> Promise<OutstandingOrder> {
        return httpClient.send(apiURLRequestFactory.makeGetOutstandingOrderRequest(id: outstandingOrderID ?? preconditionFailure()))
            .map { try JSONDecoder().decode(OutstandingOrder.self, from: $0.data) }
    }
    
    private func getOutstandingOrderConstructedItems() -> Promise<[ConstructedItem]> {
        return httpClient.send(apiURLRequestFactory.makeGetOutstandingOrderConstructedItemsRequest(id: outstandingOrderID ?? preconditionFailure()))
            .map { try JSONDecoder().decode([ConstructedItem].self, from: $0.data) }
    }
    
    private func partiallyUpdateOutstandingOrderConstructedItem(constructedItemID: ConstructedItem.ID, data: PartiallyUpdateOutstandingOrderConstructedItemData) -> Promise<ConstructedItem> {
        do {
            return try httpClient.send(apiURLRequestFactory.makePartiallyUpdateOutstandingOrderConstructedItemRequest(
                outstandingOrderID: outstandingOrderID ?? preconditionFailure(),
                constructedItemID: constructedItemID,
                data: data
            )).validate().map { try JSONDecoder().decode(ConstructedItem.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
    }
    
    private func removeOutstandingOrderConstructedItem(outstandingOrderID: OutstandingOrder.ID, constructedItemID: ConstructedItem.ID) -> Promise<OutstandingOrder> {
        return httpClient.send(apiURLRequestFactory.makeRemoveOutstandingOrderConstructedItem(outstandingOrderID: outstandingOrderID, constructedItemID: constructedItemID)).validate()
            .map { try JSONDecoder().decode(OutstandingOrder.self, from: $0.data) }
    }
    
    // MARK: - Section Model Methods
    private func makeTableViewSectionModels() -> [UITableViewSectionModel] {
        var sectionModels = [UITableViewSectionModel]()
        if let constructedItemsModel = constructedItemsTableViewSectionModel { sectionModels.append(constructedItemsModel) }
        return sectionModels
    }
    
    private func makeConstructedItemsTableViewSectionModel(constructedItems: [ConstructedItem]) -> UITableViewSectionModel {
        return UITableViewSectionModel(cellViewModels: constructedItems.map { self.makeConstructedItemStackTableViewCellViewModel(constructedItem: $0) })
    }
    
    // MARK: - Cell View Model Methods
    private func makeConstructedItemStackTableViewCellViewModel(constructedItem: ConstructedItem) -> UITableViewCellViewModel {
        return ConstructedItemStackTableViewCellViewModel(
            identifier: OutstandingOrderViewController.CellIdentifier.constructedItemStackTableViewCell.rawValue,
            height: Constants.constructedItemStackCellViewModelHeight,
            actions: constructedItemStackCellViewModelActions,
            configurationData: .init(
                nameText: constructedItem.name,
                priceText: constructedItem.totalPrice?.toDollarUnits().priceString,
                quantityText: constructedItem.quantity?.toString(),
                constructedItemID: constructedItem.id
            )
        )
    }
}

extension OutstandingOrderViewModel {
    struct ConstructedItemStackTableViewCellViewModel: UITableViewCellViewModel {
        let identifier: String
        let height: Double
        let actions: [UITableViewCellAction: UITableViewCellActionHandler]
        let configurationData: ConfigurationData
        
        struct ConfigurationData {
            let nameText: String?
            let priceText: String?
            let quantityText: String?
            let constructedItemID: ConstructedItem.ID
        }
    }
}

enum OutstandingOrderViewModelError: Error {
    case noOutstandingOrders
}
