//
//  ConstructedItemViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/25/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit
import FirebaseAuth

class ConstructedItemViewModel {
    private let apiURLRequestFactory = APIURLRequestFactory()
    
    // MARK: - Dependencies
    var httpClient: HTTPClient
    var keyValueStore: KeyValueStore
    var userAuthManager: UserAuthManager
    
    // MARK: - View Settable Properties
    /// The category ID of the presented constructed item. Required to be non-`nil`.
    /// Used to get the available categories of the constructed item,
    /// the subcategories of this category.
    var categoryID: Category.ID?
    /// The presented constructed item's ID. Required to be non-`nil`.
    /// Call `beginCreateConstructedItemDownload()` to create a new one.
    var constructedItemID: ConstructedItem.ID?
    /// The ID of the outstanding order to add the constructed item to.
    /// If not set, will attempt to set when
    /// beginAddToOutstandingOrderDownload() is called.
    var outstandingOrderID: OutstandingOrder.ID?
    var userID: User.ID?
    
    var categoryRoundedTextCollectionViewCellViewModelActions = [UICollectionViewCellAction: UICollectionViewCellActionHandler]()
    var categoryRoundedTextCollectionViewCellViewModelSize: ((CategoryRoundedTextCollectionViewCellViewModel) -> (width: Double, height: Double))?
    var errorHandler: ((Error) -> Void)?
    
    // MARK: - View Gettable Properties
    var isUserSignedIn: Bool { return userAuthManager.isUserSignedIn }
    
    // MARK: - Dynamic Properties
    /// The selected category ID to present its items.
    let selectedCategoryID: Dynamic<Category.ID?> = Dynamic(nil)
    let selectedCategoryName: Dynamic<String?> = Dynamic(nil)
    let categoryCollectionViewSectionModels = Dynamic([UICollectionViewSectionModel]())
    let isCategoriesDownloading = Dynamic(false)
    let totalPriceText: Dynamic<String?> = Dynamic(nil)
    let isFavorite: Dynamic<Bool?> = Dynamic(false)
    
    enum CellIdentifier: String {
        case roundedTextCollectionViewCell
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
        firstly { beginCategoriesDownload() }
            .catch { self.errorHandler?($0) }
    }
    
    func beginCreateConstructedItemDownload() {
        let constructedItemPromise: Promise<ConstructedItem>
        if userID != nil {
            constructedItemPromise = userAuthManager.getCurrentUserIDToken().then { token in
                self.getUser(token: token)
                    .then { self.createConstructedItem(data: .init(categoryID: self.categoryID ?? preconditionFailure(), userID: $0.id), token: token) }
            }
        } else {
            constructedItemPromise = createConstructedItem(data: .init(categoryID: categoryID ?? preconditionFailure()))
        }
        constructedItemPromise
            .done { self.constructedItemID = $0.id }
            .catch { self.errorHandler?($0) }
    }
    
    func beginAddConstructedItemItemsDownload(categoryItemIDs: [Item.CategoryItemID]) {
        let promise: Promise<Void>
        if userID != nil {
            promise = userAuthManager.getCurrentUserIDToken()
                .then { self.beginAddConstructedItemItemsDownload(categoryItemIDs: categoryItemIDs, token: $0)  }
        }
        else { promise = beginAddConstructedItemItemsDownload(categoryItemIDs: categoryItemIDs) }
        promise.catch { self.errorHandler?($0) }
    }
    
    func beginRemoveConstructedItemItemsDownload(categoryItemID: Item.CategoryItemID) {
        let promise: Promise<Void>
        if userID != nil {
            promise = userAuthManager.getCurrentUserIDToken()
                .then { self.beginRemoveConstructedItemItemsDownload(categoryItemID: categoryItemID, token: $0)  }
        }
        else { promise = beginRemoveConstructedItemItemsDownload(categoryItemID: categoryItemID) }
        promise.catch { self.errorHandler?($0) }
    }
    
    func beginFavoriteDownload(isFavorite: Bool) {
        userAuthManager.getCurrentUserIDToken()
            .then { self.partiallyUpdateConstructedItem(data: .init(isFavorite: isFavorite), token: $0) }
            .done { self.isFavorite.value = $0.isFavorite }
            .catch { self.errorHandler?($0) }
    }
    
    func beginUpdateConstructedItemUserDownload() {
        userAuthManager.getCurrentUserIDToken()
            .then { self.partiallyUpdateConstructedItem(data: .init(userID: self.userID ?? preconditionFailure()), token: $0) }
            .catch { self.errorHandler?($0) }
    }
    
    func beginAddToOutstandingOrderDownload(successHandler: (() -> Void)? = nil) {
        let promise: Promise<Void>
        if userID != nil {
            promise = userAuthManager.getCurrentUserIDToken()
                .then { self.beginOutstandingOrderAndAddToOutstandingOrderDownload(token: $0) }
        } else { promise = self.beginOutstandingOrderAndAddToOutstandingOrderDownload() }
        promise.done { successHandler?() }
            .catch { self.errorHandler?($0) }
    }
    
    func beginUserDownload(successHandler: (() -> Void)? = nil) {
        userAuthManager.getCurrentUserIDToken()
            .then { self.getTokenUser(token: $0) }
            .get { self.userID = $0.id }.asVoid()
            .done { successHandler?() }
            .catch { self.errorHandler?($0) }
    }
    
    private func beginCategoriesDownload() -> Promise<Void> {
        isCategoriesDownloading.value = true
        return getCategories().done { categories in
            self.selectedCategoryID.value = categories.first?.id
            self.selectedCategoryName.value = categories.first?.name
            self.categoryCollectionViewSectionModels.value = self.makeCategoryCollectionViewSectionModels(categories: categories)
        }.ensure { self.isCategoriesDownloading.value = false }
    }
    
    private func beginAddConstructedItemItemsDownload(categoryItemIDs: [Item.CategoryItemID], token: JWT? = nil) -> Promise<Void> {
        return addConstructedItemItems(data: .init(categoryItemIDs: categoryItemIDs), token: token).done { constructedItem in
            if let totalPrice = constructedItem.totalPrice {
                if totalPrice > 0 { self.totalPriceText.value = String(totalPrice.toDollarUnits().toPriceString()) }
                else { self.totalPriceText.value = nil }
            }
        }
    }
    
    private func beginRemoveConstructedItemItemsDownload(categoryItemID: Item.CategoryItemID, token: JWT? = nil) -> Promise<Void> {
        return removeConstructedItemItem(categoryItemID: categoryItemID, token: token).done { constructedItem in
            if let totalPrice = constructedItem.totalPrice {
                if totalPrice > 0 { self.totalPriceText.value = String(totalPrice.toDollarUnits().toPriceString()) }
                else { self.totalPriceText.value = nil }
            }
        }
    }
    
    private func beginOutstandingOrderDownload(token: JWT? = nil) -> Promise<Void> {
        let outstandingOrderPromise: Promise<OutstandingOrder>
        if let storedOutstandingOrderIDString = keyValueStore.value(of: String.self, forKey: KeyValueStoreKeys.currentOutstandingOrderID) {
            outstandingOrderID = OutstandingOrder.ID(uuidString: storedOutstandingOrderIDString)
            return Promise { $0.fulfill(()) }
        } else if userID != nil {
            guard let token = token else { preconditionFailure() }
            outstandingOrderPromise = getUserOutstandingOrders(token: token).then { outstandingOrders -> Promise<OutstandingOrder> in
                guard let outstandingOrder = outstandingOrders.first else { return self.createOutstandingOrder(data: .init(userID: self.userID), token: token) }
                return Promise { $0.fulfill(outstandingOrder) }
            }
        } else { outstandingOrderPromise = createOutstandingOrder() }
        return outstandingOrderPromise.done {
            self.outstandingOrderID = $0.id
            self.keyValueStore.set($0.id.uuidString, forKey: KeyValueStoreKeys.currentOutstandingOrderID)
        }
    }
    
    private func beginAddToOutstandingOrderDownload(token: JWT? = nil) -> Promise<Void> {
        return addOutstandingOrderConstructedItems(
            outstandingOrderID: outstandingOrderID ?? preconditionFailure(), data: .init(ids: [self.constructedItemID ?? preconditionFailure()]), token: token
        ).asVoid()
    }
    
    private func beginOutstandingOrderAndAddToOutstandingOrderDownload(token: JWT? = nil) -> Promise<Void> {
        let promise: Promise<Void>
        if outstandingOrderID != nil {
            promise = beginAddToOutstandingOrderDownload(token: token)
        } else {
            promise = beginOutstandingOrderDownload(token: token)
                .then { self.beginAddToOutstandingOrderDownload(token: token) }
        }
        return promise
    }
    
    private func getCategories() -> Promise<[Category]> {
        return httpClient.send(apiURLRequestFactory.makeGetSubcategoriesRequest(parentCategoryID: categoryID ?? preconditionFailure()))
            .map { try JSONDecoder().decode([Category].self, from: $0.data) }
    }
    
    private func createConstructedItem(data: CreateConstructedItemData, token: JWT? = nil) -> Promise<ConstructedItem> {
        do {
            return try httpClient.send(apiURLRequestFactory.makeCreateConstructedItemRequest(data: data, token: token)).validate()
                .map { try JSONDecoder().decode(ConstructedItem.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
    }
    
    private func addConstructedItemItems(data: AddConstructedItemItemsData, token: JWT? = nil) -> Promise<ConstructedItem> {
        do {
            return try httpClient.send(apiURLRequestFactory.makeAddConstructedItemItemsRequest(id: constructedItemID ?? preconditionFailure(), data: data, token: token)).validate()
                .map { try JSONDecoder().decode(ConstructedItem.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
    }
    
    private func removeConstructedItemItem(categoryItemID: Item.CategoryItemID, token: JWT? = nil) -> Promise<ConstructedItem> {
        return httpClient.send(apiURLRequestFactory.makeRemoveConstructedItemItemsRequest(constructedItemID: constructedItemID ?? preconditionFailure(), categoryItemID: categoryItemID, token: token)).validate()
            .map { try JSONDecoder().decode(ConstructedItem.self, from: $0.data) }
    }
    
    private func partiallyUpdateConstructedItem(data: PartiallyUpdateConstructedItemData, token: JWT? = nil) -> Promise<ConstructedItem> {
        do {
            return try  httpClient.send(apiURLRequestFactory.makePartiallyUpdateConstructedItemRequest(id: constructedItemID ?? preconditionFailure(), data: data, token: token)).validate()
            .map { try JSONDecoder().decode(ConstructedItem.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
    }
    
    private func getUserOutstandingOrders(token: JWT) -> Promise<[OutstandingOrder]> {
        return httpClient.send(apiURLRequestFactory.makeGetUserOutstandingOrdersRequest(id: userID ?? preconditionFailure(), token: token)).validate()
            .map { try JSONDecoder().decode([OutstandingOrder].self, from: $0.data) }
    }
    
    private func createOutstandingOrder(data: CreateOutstandingOrderData = .init(), token: JWT? = nil) -> Promise<OutstandingOrder> {
        do {
            return try httpClient.send(apiURLRequestFactory.makeCreateOutstandingOrderRequest(data: data, token: token)).validate()
                .map { try JSONDecoder().decode(OutstandingOrder.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
    }
    
    private func addOutstandingOrderConstructedItems(outstandingOrderID: OutstandingOrder.ID, data: AddOutstandingOrderConstructedItemsData, token: JWT? = nil) -> Promise<OutstandingOrder> {
        do {
            return try httpClient.send(apiURLRequestFactory.makeAddOutstandingOrderConstructedItemsRequest(id: outstandingOrderID, data: data, token: token)).validate()
                .map { try JSONDecoder().decode(OutstandingOrder.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
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
    private func makeCategoryCollectionViewSectionModels(categories: [Category]) -> [UICollectionViewSectionModel] {
        return [UICollectionViewSectionModel(cellViewModels: categories.map(makeCategoryRoundedTextCollectionViewCellViewModel))]
    }
    
    // MARK: - Cell View Model Methods
    private func makeCategoryRoundedTextCollectionViewCellViewModel(category: Category) -> CategoryRoundedTextCollectionViewCellViewModel {
        var cellViewModel = CategoryRoundedTextCollectionViewCellViewModel(
            identifier: CellIdentifier.roundedTextCollectionViewCell.rawValue,
            size: (0, 0),
            actions: categoryRoundedTextCollectionViewCellViewModelActions,
            configurationData: .init(text: category.name),
            selectionData: .init(categoryID: category.id, categoryName: category.name)
        )
        if let size = categoryRoundedTextCollectionViewCellViewModelSize?(cellViewModel) {
            cellViewModel.size = size
        }
        return cellViewModel
    }
}

extension ConstructedItemViewModel {
    struct CategoryRoundedTextCollectionViewCellViewModel: UICollectionViewCellViewModel {
        let identifier: String
        var size: (width: Double, height: Double)
        let actions: [UICollectionViewCellAction: UICollectionViewCellActionHandler]
        
        let configurationData: ConfigurationData
        let selectionData: SelectionData
        
        struct ConfigurationData {
            let text: String
        }
        
        struct SelectionData {
            let categoryID: Category.ID
            let categoryName: String
        }
    }
}
