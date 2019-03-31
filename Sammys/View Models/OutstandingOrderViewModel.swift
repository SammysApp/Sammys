//
//  OutstandingOrderViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/7/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit
import FirebaseAuth

class OutstandingOrderViewModel {
    private let apiURLRequestFactory = APIURLRequestFactory()
    
    // MARK: - Dependencies
    var httpClient: HTTPClient
    var keyValueStore: KeyValueStore
    var userAuthManager: UserAuthManager
    
    // MARK: - Section Model Properties
    private var constructedItemsTableViewSectionModel: UITableViewSectionModel? {
        didSet { tableViewSectionModels.value = makeTableViewSectionModels() }
    }
    
    // MARK: - View Settable Properties
    /// The bag's outstanding order's ID.
    /// Calling `beginDownloads()` will first attempt to get one if not set.
    var outstandingOrderID: OutstandingOrder.ID?
    var userID: User.ID?
    
    var constructedItemStackCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]()
    var errorHandler: ((Error) -> Void)?
    
    // MARK: - View Gettable Properties
    var isUserSignedIn: Bool { return userAuthManager.isUserSignedIn }
    
    // MARK: - Dynamic Properties
    let tableViewSectionModels = Dynamic([UITableViewSectionModel]())
    let isOutstandingOrderDownloading = Dynamic(false)
    let isItemsDownloading = Dynamic(false)
    let taxPriceText: Dynamic<String?> = Dynamic(nil)
    let subtotalPriceText: Dynamic<String?> = Dynamic(nil)
    
    enum CellIdentifier: String {
        case constructedItemStackTableViewCell
    }
    
    init(httpClient: HTTPClient = URLSession.shared,
         keyValueStore: KeyValueStore = UserDefaults.standard,
         userAuthManager: UserAuthManager = Auth.auth()) {
        self.httpClient = httpClient
        self.keyValueStore = keyValueStore
        self.userAuthManager = userAuthManager
    }
    
    // MARK: - Download Methods
    func beginDownloads() {
        let outstandingOrderPromise: Promise<Void>
        if outstandingOrderID == nil {
            if let idString = keyValueStore.value(of: String.self, forKey: KeyValueStoreKeys.currentOutstandingOrderID),
                let id = OutstandingOrder.ID(uuidString: idString) {
                outstandingOrderID = id
                outstandingOrderPromise = beginOutstandingOrderDownload()
            } else { errorHandler?(OutstandingOrderViewModelError.noOutstandingOrders); return }
        }
        // TODO: Check if user has order.
        else {
            outstandingOrderPromise = beginOutstandingOrderDownload()
        }
        outstandingOrderPromise.catch { self.errorHandler?($0) }
    }
    
    func beginUpdateConstructedItemQuantityDownload(constructedItemID: ConstructedItem.ID, quantity: Int) {
        let promise: Promise<Void>
        if userID != nil {
            promise = userAuthManager.getCurrentUserIDToken()
                .then { self.beginUpdateConstructedItemQuantityOrRemoveDownload(constructedItemID: constructedItemID, quantity: quantity, token: $0) }
        } else { promise = beginUpdateConstructedItemQuantityOrRemoveDownload(constructedItemID: constructedItemID, quantity: quantity) }
        promise.then { self.beginOutstandingOrderConstructedItemsDownload() }
            .catch { self.errorHandler?($0) }
    }
    
    func beginUserDownload(successHandler: (() -> Void)? = nil) {
        userAuthManager.getCurrentUserIDToken()
            .then { self.getTokenUser(token: $0) }
            .get { self.userID = $0.id }.asVoid()
            .done { successHandler?() }
            .catch { self.errorHandler?($0) }
    }
    
    private func beginOutstandingOrderDownload() -> Promise<Void> {
        let outstandingOrderPromise: Promise<OutstandingOrder>
        if userID != nil {
            outstandingOrderPromise = userAuthManager.getCurrentUserIDToken()
                .then { self.getOutstandingOrder(token: $0) }
            // TODO: Ensure order has this userID or set it.
        } else { outstandingOrderPromise = getOutstandingOrder() }
        return outstandingOrderPromise.done { outstandingOrder in
            self.outstandingOrderID = outstandingOrder.id
            self.taxPriceText.value = outstandingOrder.taxPrice?.toUSDUnits().toPriceString()
            self.subtotalPriceText.value = outstandingOrder.totalPrice?.toUSDUnits().toPriceString()
        }.then { () -> Promise<Void> in
            self.isItemsDownloading.value = true
            return self.beginOutstandingOrderConstructedItemsDownload()
                .ensure { self.isItemsDownloading.value = false }
        }
    }
    
    private func beginOutstandingOrderConstructedItemsDownload() -> Promise<Void> {
        let constructedItemsPromise: Promise<[ConstructedItem]>
        if userID != nil {
            constructedItemsPromise = userAuthManager.getCurrentUserIDToken()
                .then { self.getOutstandingOrderConstructedItems(token: $0) }
        } else { constructedItemsPromise = getOutstandingOrderConstructedItems() }
        return constructedItemsPromise.done { self.constructedItemsTableViewSectionModel = self.makeConstructedItemsTableViewSectionModel(constructedItems: $0) }
    }
    
    private func beginUpdateConstructedItemQuantityOrRemoveDownload(constructedItemID: ConstructedItem.ID, quantity: Int, token: JWT? = nil) -> Promise<Void> {
        let promise: Promise<Void>
        if quantity > 0 {
            promise = partiallyUpdateOutstandingOrderConstructedItem(constructedItemID: constructedItemID, data: .init(quantity: quantity), token: token).asVoid()
        } else {
            promise = removeOutstandingOrderConstructedItem(outstandingOrderID: outstandingOrderID ?? preconditionFailure(), constructedItemID: constructedItemID, token: token).asVoid()
        }
        return promise
    }
    
    private func getOutstandingOrder(token: JWT? = nil) -> Promise<OutstandingOrder> {
        return httpClient.send(apiURLRequestFactory.makeGetOutstandingOrderRequest(id: outstandingOrderID ?? preconditionFailure(), token: token)).validate()
            .map { try JSONDecoder().decode(OutstandingOrder.self, from: $0.data) }
    }
    
    private func getOutstandingOrderConstructedItems(token: JWT? = nil) -> Promise<[ConstructedItem]> {
        return httpClient.send(apiURLRequestFactory.makeGetOutstandingOrderConstructedItemsRequest(id: outstandingOrderID ?? preconditionFailure(), token: token)).validate()
            .map { try JSONDecoder().decode([ConstructedItem].self, from: $0.data) }
    }
    
    private func partiallyUpdateOutstandingOrderConstructedItem(constructedItemID: ConstructedItem.ID, data: PartiallyUpdateOutstandingOrderConstructedItemData, token: JWT? = nil) -> Promise<ConstructedItem> {
        do {
            return try httpClient.send(apiURLRequestFactory.makePartiallyUpdateOutstandingOrderConstructedItemRequest(
                outstandingOrderID: outstandingOrderID ?? preconditionFailure(),
                constructedItemID: constructedItemID,
                data: data,
                token: token
            )).validate().map { try JSONDecoder().decode(ConstructedItem.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
    }
    
    private func removeOutstandingOrderConstructedItem(outstandingOrderID: OutstandingOrder.ID, constructedItemID: ConstructedItem.ID, token: JWT? = nil) -> Promise<OutstandingOrder> {
        return httpClient.send(apiURLRequestFactory.makeRemoveOutstandingOrderConstructedItem(outstandingOrderID: outstandingOrderID, constructedItemID: constructedItemID, token: token)).validate()
            .map { try JSONDecoder().decode(OutstandingOrder.self, from: $0.data) }
    }
    
    private func getUser(token: JWT) -> Promise<User> {
        return httpClient.send(apiURLRequestFactory.makeGetUserRequest(id: userID ?? preconditionFailure(), token: token)).validate()
            .map { try JSONDecoder().decode(User.self, from: $0.data) }
    }
    
    private func getTokenUser(token: JWT) -> Promise<User> {
        return httpClient.send(apiURLRequestFactory.makeGetTokenUserRequest(token: token)).validate()
            .map { try JSONDecoder().decode(User.self, from: $0.data) }
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
            identifier: CellIdentifier.constructedItemStackTableViewCell.rawValue,
            height: .automatic,
            actions: constructedItemStackCellViewModelActions,
            configurationData: .init(
                nameText: constructedItem.name,
                descriptionText: constructedItem.description,
                priceText: constructedItem.totalPrice?.toUSDUnits().toPriceString(),
                quantityText: constructedItem.quantity?.toString(),
                constructedItemID: constructedItem.id
            )
        )
    }
}

extension OutstandingOrderViewModel {
    struct ConstructedItemStackTableViewCellViewModel: UITableViewCellViewModel {
        let identifier: String
        let height: UITableViewCellViewModelHeight
        let actions: [UITableViewCellAction: UITableViewCellActionHandler]
        let configurationData: ConfigurationData
        
        struct ConfigurationData {
            let nameText: String?
            let descriptionText: String?
            let priceText: String?
            let quantityText: String?
            let constructedItemID: ConstructedItem.ID
        }
    }
}

enum OutstandingOrderViewModelError: Error {
    case noOutstandingOrders
}
