//
//  PurchasedItemsViewModel.swift
//  Kitchen
//
//  Created by Natanel Niazoff on 4/18/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

class PurchasedItemsViewModel {
    private let apiURLRequestFactory = APIURLRequestFactory()
    
    private var purchasedConstructedItems = [PurchasedConstructedItem]()
    
    // MARK: - Dependencies
    var httpClient: HTTPClient
    
    // MARK: - Section Model Properties
    private var purchasedConstructedItemsTableViewSectionModel: UITableViewSectionModel? {
        didSet { updateTableViewSectionModels() }
    }
    
    // MARK: - View Settable Properties
    var purchasedOrderID: PurchasedOrder.ID?
    
    var purchasedConstructedItemTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]()
    
    var errorHandler: (Error) -> Void = { _ in }
    
    // MARK: - Dynamic Properties
    private(set) lazy var tableViewSectionModels = Dynamic(makeTableViewSectionModels())
    
    enum CellIdentifier: String {
        case itemTableViewCell
    }
    
    private struct Constants {
        static let purchasedConstructedItemTableViewCellViewModelHeight = Double(100)
    }
    
    init(httpClient: HTTPClient = URLSession.shared) {
        self.httpClient = httpClient
    }
    
    // MARK: - Setup Methods
    private func setUp(for purchasedConstructedItems: [PurchasedConstructedItem]) {
        self.purchasedConstructedItems = purchasedConstructedItems
        updatePurchasedConstructedItemsTableViewSectionModel()
    }
    
    private func updatePurchasedConstructedItemsTableViewSectionModel() {
        purchasedConstructedItemsTableViewSectionModel = makePurchasedConstructedItemsTableViewSectionModel(purchasedConstructedItems: purchasedConstructedItems)
    }
    
    private func updateTableViewSectionModels() {
        tableViewSectionModels.value = makeTableViewSectionModels()
    }
    
    // MARK: - Download Methods
    func beginDownloads() {
        beginPurchasedConstructedItemsDownload()
            .catch(errorHandler)
    }
    
    private func beginPurchasedConstructedItemsDownload() -> Promise<Void> {
        return getPurchasedConstructedItems().done(setUp)
    }
    
    private func getPurchasedConstructedItems() -> Promise<[PurchasedConstructedItem]> {
        return httpClient.send(apiURLRequestFactory.makeGetPurchasedOrderConstructedItems(id: purchasedOrderID ?? preconditionFailure())).validate()
            .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode([PurchasedConstructedItem].self, from: $0.data) }
    }
    
    // MARK: - Section Model Methods
    private func makePurchasedConstructedItemsTableViewSectionModel(purchasedConstructedItems: [PurchasedConstructedItem]) -> UITableViewSectionModel {
        return UITableViewSectionModel(cellViewModels: purchasedConstructedItems.map(makePurchasedConstructedItemTableViewCellViewModel))
    }
    
    private func makeTableViewSectionModels() -> [UITableViewSectionModel] {
        var sectionModels = [UITableViewSectionModel]()
        if let purchasedConstructedItemsModel = purchasedConstructedItemsTableViewSectionModel {
            sectionModels.append(purchasedConstructedItemsModel)
        }
        return sectionModels
    }
    
    // MARK: - Cell Model Methods
    private func makePurchasedConstructedItemTableViewCellViewModel(purchasedConstructedItem: PurchasedConstructedItem) -> PurchasedConstructedItemTableViewCellViewModel {
        return PurchasedConstructedItemTableViewCellViewModel(
            identifier: CellIdentifier.itemTableViewCell.rawValue,
            height: .fixed(Constants.purchasedConstructedItemTableViewCellViewModelHeight),
            actions: purchasedConstructedItemTableViewCellViewModelActions,
            configurationData: .init(titleText: purchasedConstructedItem.name)
        )
    }
}

extension PurchasedItemsViewModel {
    struct PurchasedConstructedItemTableViewCellViewModel: UITableViewCellViewModel {
        let identifier: String
        let height: UITableViewCellViewModelHeight
        let actions: [UITableViewCellAction: UITableViewCellActionHandler]
        let configurationData: ConfigurationData
        
        struct ConfigurationData {
            let titleText: String?
        }
    }
}
