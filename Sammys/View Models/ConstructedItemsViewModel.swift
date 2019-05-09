//
//  ConstructedItemsViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/8/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit
import FirebaseAuth

class ConstructedItemsViewModel {
    private let apiURLRequestFactory = APIURLRequestFactory()
    
    private var constructedItems = [ConstructedItem]()
    
    // MARK: - Dependencies
    var httpClient: HTTPClient
    var keyValueStore: KeyValueStore
    var userAuthManager: UserAuthManager
    
    // MARK: - View Settable Properties
    var userID: User.ID?
    
    var outstandingOrderID: OutstandingOrder.ID?
    
    var isFavorites: Bool? = nil
    
    var constructedItemCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]() {
        didSet { updateConstructedItemsTableViewSectionModel() }
    }
    
    var errorHandler: (Error) -> Void = { _ in }
    
    // MARK: - View Gettable Properties
    var isUserSignedIn: Bool { return userAuthManager.isUserSignedIn }
    
    // MARK: - Dynamic Properties
    private(set) lazy var tableViewSectionModels = Dynamic(makeTableViewSectionModels())
    
    // MARK: - Section Model Properties
    private var constructedItemsTableViewSectionModel: UITableViewSectionModel? {
        didSet { updateTableViewSectionModels() }
    }
    
    enum CellIdentifier: String {
        case itemTableViewCell
    }
    
    init(httpClient: HTTPClient = URLSession.shared,
         keyValueStore: KeyValueStore = UserDefaults.standard,
         userAuthManager: UserAuthManager = Auth.auth()) {
        self.httpClient = httpClient
        self.keyValueStore = keyValueStore
        self.userAuthManager = userAuthManager
    }
    
    // MARK: - Setup Methods
    private func setUp(for constructedItems: [ConstructedItem]) {
        self.constructedItems = constructedItems
        updateConstructedItemsTableViewSectionModel()
    }
    
    private func setUp(for outstandingOrderID: OutstandingOrder.ID) {
        self.outstandingOrderID = outstandingOrderID
    }
    
    private func updateConstructedItemsTableViewSectionModel() {
        constructedItemsTableViewSectionModel = makeConstructedItemsTableViewSectionModel(constructedItems: constructedItems)
    }
    
    private func updateTableViewSectionModels() {
        tableViewSectionModels.value = makeTableViewSectionModels()
    }
    
    // MARK: - Download Methods
    func beginDownloads() {
        firstly { self.beginConstructedItemsDownload() }
            .catch(errorHandler)
    }
    
    func beginUpdateConstructedItemDownload(id: ConstructedItem.ID, isFavorite: Bool) {
        userAuthManager.getCurrentUserIDToken()
            .then { self.partiallyUpdateConstructedItem(id: id, data: .init(isFavorite: isFavorite), token: $0).asVoid() }
            .then { self.beginConstructedItemsDownload() }
            .catch(errorHandler)
    }
    
    func beginAddToOutstandingOrderDownload(constructedItemID: ConstructedItem.ID, successHandler: @escaping () -> Void = {}) {
        userAuthManager.getCurrentUserIDToken()
            .then { self.makeAddToOutstandingOrderDownload(constructedItemID: constructedItemID, token: $0) }
            .done(successHandler)
            .catch(errorHandler)
    }
    
    func beginUserIDDownload(successHandler: @escaping () -> Void = {}) {
        userAuthManager.getCurrentUserIDToken()
            .then { self.getTokenUser(token: $0) }
            .get { self.userID = $0.id }.asVoid()
            .done(successHandler)
            .catch(errorHandler)
    }
    
    private func beginConstructedItemsDownload() -> Promise<Void> {
        return userAuthManager.getCurrentUserIDToken()
            .then { self.getConstructedItems(token: $0) }
            .done(setUp)
    }
    
    private func beginOutstandingOrderIDDownload(token: JWT) -> Promise<Void> {
        return makeOutstandingOrderIDDownload(token: token).done(setUp)
    }
    
    private func beginAddToOutstandingOrderDownload(constructedItemID: ConstructedItem.ID, token: JWT) -> Promise<Void> {
        return self.addOutstandingOrderConstructedItems(outstandingOrderID: self.outstandingOrderID ?? preconditionFailure(), data: .init(ids: [constructedItemID]), token: token).asVoid()
    }
    
    private func makeOutstandingOrderIDDownload(token: JWT) -> Promise<OutstandingOrder.ID> {
        if let storedOutstandingOrderIDString = keyValueStore.value(of: String.self, forKey: KeyValueStoreKeys.currentOutstandingOrderID),
            let id = OutstandingOrder.ID(uuidString: storedOutstandingOrderIDString) {
            return Promise { $0.fulfill((id)) }
        } else {
            return getOutstandingOrders(token: token).then { outstandingOrders -> Promise<OutstandingOrder> in
                if let outstandingOrder = outstandingOrders.first { return Promise { $0.fulfill(outstandingOrder) } }
                else { return self.createOutstandingOrder(data: .init(userID: self.userID ?? preconditionFailure()), token: token) }
                }.map { $0.id }
        }
    }
    
    private func makeAddToOutstandingOrderDownload(constructedItemID: ConstructedItem.ID, token: JWT) -> Promise<Void> {
        if outstandingOrderID != nil {
            return beginAddToOutstandingOrderDownload(constructedItemID: constructedItemID, token: token)
        } else {
            return beginOutstandingOrderIDDownload(token: token)
                .then { self.beginAddToOutstandingOrderDownload(constructedItemID: constructedItemID, token: token) }
        }
    }
    
    private func getConstructedItems(token: JWT) -> Promise<[ConstructedItem]> {
        return httpClient.send(apiURLRequestFactory.makeGetUserConstructedItemsRequest(id: userID ?? preconditionFailure(), queryData: .init(isFavorite: isFavorites), token: token)).validate()
            .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode([ConstructedItem].self, from: $0.data) }
    }
    
    private func partiallyUpdateConstructedItem(id: ConstructedItem.ID, data: PartiallyUpdateConstructedItemRequestData, token: JWT) -> Promise<ConstructedItem> {
        do {
            return try  httpClient.send(apiURLRequestFactory.makePartiallyUpdateConstructedItemRequest(id: id, data: data, token: token)).validate()
                .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode(ConstructedItem.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
    }
    
    private func getOutstandingOrders(token: JWT) -> Promise<[OutstandingOrder]> {
        return httpClient.send(apiURLRequestFactory.makeGetUserOutstandingOrdersRequest(id: userID ?? preconditionFailure(), token: token)).validate()
            .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode([OutstandingOrder].self, from: $0.data) }
    }
    
    private func createOutstandingOrder(data: CreateOutstandingOrderRequestData = .init(), token: JWT) -> Promise<OutstandingOrder> {
        do {
            return try httpClient.send(apiURLRequestFactory.makeCreateOutstandingOrderRequest(data: data, token: token)).validate()
                .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode(OutstandingOrder.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
    }
    
    private func addOutstandingOrderConstructedItems(outstandingOrderID: OutstandingOrder.ID, data: AddOutstandingOrderConstructedItemsRequestData, token: JWT) -> Promise<OutstandingOrder> {
        do {
            return try httpClient.send(apiURLRequestFactory.makeAddOutstandingOrderConstructedItemsRequest(id: outstandingOrderID, data: data, token: token)).validate()
                .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode(OutstandingOrder.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
    }
    
    private func getTokenUser(token: JWT) -> Promise<User> {
        return httpClient.send(apiURLRequestFactory.makeGetTokenUserRequest(token: token)).validate()
            .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode(User.self, from: $0.data) }
    }
    
    // MARK: - Section Model Methods
    private func makeConstructedItemsTableViewSectionModel(constructedItems: [ConstructedItem]) -> UITableViewSectionModel? {
        guard !constructedItems.isEmpty else { return nil }
        return UITableViewSectionModel(cellViewModels: constructedItems.map { self.makeConstructedItemTableViewCellViewModel(constructedItem: $0) })
    }
    
    private func makeTableViewSectionModels() -> [UITableViewSectionModel] {
        var sectionModels = [UITableViewSectionModel]()
        if let constructedItemsModel = constructedItemsTableViewSectionModel {
            sectionModels.append(constructedItemsModel)
        }
        return sectionModels
    }
    
    // MARK: - Cell View Model Methods
    private func makeConstructedItemTableViewCellViewModel(constructedItem: ConstructedItem) -> UITableViewCellViewModel {
        return ConstructedItemTableViewCellViewModel(
            identifier: CellIdentifier.itemTableViewCell.rawValue,
            height: .automatic,
            actions: constructedItemCellViewModelActions,
            configurationData: .init(
                titleText: constructedItem.name,
                descriptionText: constructedItem.description,
                priceText: constructedItem.totalPrice?.toUSDUnits().toPriceString()
            ),
            selectionData: .init(constructedItemID: constructedItem.id, isFavorite: constructedItem.isFavorite)
        )
    }
}

extension ConstructedItemsViewModel {
    struct ConstructedItemTableViewCellViewModel: UITableViewCellViewModel {
        let identifier: String
        let height: UITableViewCellViewModelHeight
        let actions: [UITableViewCellAction: UITableViewCellActionHandler]
        
        let configurationData: ConfigurationData
        let selectionData: SelectionData
        
        struct ConfigurationData {
            let titleText: String?
            let descriptionText: String?
            let priceText: String?
        }
        
        struct SelectionData {
            let constructedItemID: ConstructedItem.ID
            let isFavorite: Bool
        }
    }
}
