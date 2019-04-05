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
    
    // MARK: - Section Model Properties
    private var categoriesCollectionViewSectionModel: UICollectionViewSectionModel? {
        didSet { updateCategoryCollectionViewSectionModels() }
    }
    
    // MARK: - View Settable Properties
    /// The category ID of the presented constructed item.
    /// Required to be non-`nil` before beginning downloads.
    /// Used to get the available categories of the constructed item,
    /// the subcategories of this category.
    var categoryID: Category.ID?
    /// The presented constructed item's ID.
    /// Required to be non-`nil` for many downloads.
    /// Call `beginCreateConstructedItemDownload()` to create a new one
    /// and have this property set.
    var constructedItemID: ConstructedItem.ID?
    /// The ID of the outstanding order to add the constructed item to.
    /// If not set, will attempt to set
    /// when `beginAddToOutstandingOrderDownload()` is called.
    var outstandingOrderID: OutstandingOrder.ID?
    /// Allowed to be `nil`. Required for some downloads.
    /// Use beginUserIDDownload() to attempt to set.
    var userID: User.ID?
    
    var categoryRoundedTextCollectionViewCellViewModelActions = [UICollectionViewCellAction: UICollectionViewCellActionHandler]()
    var categoryRoundedTextCollectionViewCellViewModelSize: ((CategoryRoundedTextCollectionViewCellViewModel) -> (width: Double, height: Double))?
    
    var errorHandler: ((Error) -> Void)?
    
    // MARK: - View Gettable Properties
    var isUserSignedIn: Bool { return userAuthManager.isUserSignedIn }
    
    // MARK: - Dynamic Properties
    private(set) lazy var categoryCollectionViewSectionModels = Dynamic(makeCategoryCollectionViewSectionModels())
    
    /// The selected category ID to present its items.
    let selectedCategoryID: Dynamic<Category.ID?> = Dynamic(nil)
    let selectedCategoryName: Dynamic<String?> = Dynamic(nil)
    
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
    
    // MARK: - Setup Methods
    private func setUp(for constructedItem: ConstructedItem) {
        if let totalPrice = constructedItem.totalPrice {
            if totalPrice > 0 { self.totalPriceText.value = String(totalPrice.toUSDUnits().toPriceString()) }
            else { self.totalPriceText.value = nil }
        }
    }
    
    private func updateCategoryCollectionViewSectionModels() {
        categoryCollectionViewSectionModels.value = makeCategoryCollectionViewSectionModels()
    }
    
    // MARK: - Download Methods
    func beginDownloads() {
        firstly { beginCategoriesDownload() }
            .catch { self.errorHandler?($0) }
    }
    
    func beginCreateConstructedItemDownload() {
        let constructedItemPromise: Promise<ConstructedItem>
        if let userID = userID {
            constructedItemPromise = userAuthManager.getCurrentUserIDToken().then {
                self.createConstructedItem(data: .init(categoryID: self.categoryID ?? preconditionFailure(), userID: userID), token: $0)
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
                .then { self.beginOutstandingOrderIDAndAddToOutstandingOrderDownload(token: $0) }
        } else { promise = self.beginOutstandingOrderIDAndAddToOutstandingOrderDownload() }
        promise.done { successHandler?() }
            .catch { self.errorHandler?($0) }
    }
    
    func beginUserIDDownload(successHandler: (() -> Void)? = nil) {
        userAuthManager.getCurrentUserIDToken()
            .then { self.getTokenUser(token: $0) }
            .get { self.userID = $0.id }.asVoid()
            .done { successHandler?() }
            .catch { self.errorHandler?($0) }
    }
    
    private func beginCategoriesDownload() -> Promise<Void> {
        return getCategories().done { categories in
            self.selectedCategoryID.value = categories.first?.id
            self.selectedCategoryName.value = categories.first?.name
            self.categoriesCollectionViewSectionModel = self.makeCategoriesTableViewSectionModel(categories: categories)
        }
    }
    
    private func beginAddConstructedItemItemsDownload(categoryItemIDs: [Item.CategoryItemID], token: JWT? = nil) -> Promise<Void> {
        return addConstructedItemItems(data: .init(categoryItemIDs: categoryItemIDs), token: token).done { self.setUp(for: $0) }
    }
    
    private func beginRemoveConstructedItemItemsDownload(categoryItemID: Item.CategoryItemID, token: JWT? = nil) -> Promise<Void> {
        return removeConstructedItemItem(categoryItemID: categoryItemID, token: token).done { self.setUp(for: $0) }
    }
    
    private func beginOutstandingOrderIDAndAddToOutstandingOrderDownload(token: JWT? = nil) -> Promise<Void> {
        let promise: Promise<Void>
        if outstandingOrderID != nil {
            promise = beginAddToOutstandingOrderDownload(token: token)
        } else {
            promise = beginOutstandingOrderIDDownload(token: token)
                .then { self.beginAddToOutstandingOrderDownload(token: token) }
        }
        return promise
    }
    
    private func beginOutstandingOrderIDDownload(token: JWT? = nil) -> Promise<Void> {
        let outstandingOrderPromise: Promise<OutstandingOrder>
        if let storedOutstandingOrderIDString = keyValueStore.value(of: String.self, forKey: KeyValueStoreKeys.currentOutstandingOrderID) {
            outstandingOrderID = OutstandingOrder.ID(uuidString: storedOutstandingOrderIDString)
            return Promise { $0.fulfill(()) }
        } else if userID != nil {
            guard let token = token else { preconditionFailure() }
            outstandingOrderPromise = getUserOutstandingOrders(token: token).then { outstandingOrders -> Promise<OutstandingOrder> in
                guard let outstandingOrder = outstandingOrders.first
                    else { return self.createOutstandingOrder(data: .init(userID: self.userID), token: token) }
                return Promise { $0.fulfill(outstandingOrder) }
            }
        } else { outstandingOrderPromise = createOutstandingOrder() }
        return outstandingOrderPromise.done { outstandingOrder in
            self.outstandingOrderID = outstandingOrder.id
            self.keyValueStore.set(outstandingOrder.id.uuidString, forKey: KeyValueStoreKeys.currentOutstandingOrderID)
        }
    }
    
    private func beginAddToOutstandingOrderDownload(token: JWT? = nil) -> Promise<Void> {
        return addOutstandingOrderConstructedItems(
            outstandingOrderID: outstandingOrderID ?? preconditionFailure(), data: .init(ids: [self.constructedItemID ?? preconditionFailure()]), token: token
        ).asVoid()
    }
    
    private func getCategories() -> Promise<[Category]> {
        return httpClient.send(apiURLRequestFactory.makeGetSubcategoriesRequest(parentCategoryID: categoryID ?? preconditionFailure()))
            .map { try JSONDecoder().decode([Category].self, from: $0.data) }
    }
    
    private func createConstructedItem(data: CreateConstructedItemRequestData, token: JWT? = nil) -> Promise<ConstructedItem> {
        do {
            return try httpClient.send(apiURLRequestFactory.makeCreateConstructedItemRequest(data: data, token: token)).validate()
                .map { try JSONDecoder().decode(ConstructedItem.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
    }
    
    private func addConstructedItemItems(data: AddConstructedItemItemsRequestData, token: JWT? = nil) -> Promise<ConstructedItem> {
        do {
            return try httpClient.send(apiURLRequestFactory.makeAddConstructedItemItemsRequest(id: constructedItemID ?? preconditionFailure(), data: data, token: token)).validate()
                .map { try JSONDecoder().decode(ConstructedItem.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
    }
    
    private func removeConstructedItemItem(categoryItemID: Item.CategoryItemID, token: JWT? = nil) -> Promise<ConstructedItem> {
        return httpClient.send(apiURLRequestFactory.makeRemoveConstructedItemItemsRequest(constructedItemID: constructedItemID ?? preconditionFailure(), categoryItemID: categoryItemID, token: token)).validate()
            .map { try JSONDecoder().decode(ConstructedItem.self, from: $0.data) }
    }
    
    private func partiallyUpdateConstructedItem(data: PartiallyUpdateConstructedItemRequestData, token: JWT? = nil) -> Promise<ConstructedItem> {
        do {
            return try  httpClient.send(apiURLRequestFactory.makePartiallyUpdateConstructedItemRequest(id: constructedItemID ?? preconditionFailure(), data: data, token: token)).validate()
            .map { try JSONDecoder().decode(ConstructedItem.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
    }
    
    private func getUserOutstandingOrders(token: JWT) -> Promise<[OutstandingOrder]> {
        return httpClient.send(apiURLRequestFactory.makeGetUserOutstandingOrdersRequest(id: userID ?? preconditionFailure(), token: token)).validate()
            .map { try JSONDecoder().decode([OutstandingOrder].self, from: $0.data) }
    }
    
    private func createOutstandingOrder(data: CreateOutstandingOrderRequestData = .init(), token: JWT? = nil) -> Promise<OutstandingOrder> {
        do {
            return try httpClient.send(apiURLRequestFactory.makeCreateOutstandingOrderRequest(data: data, token: token)).validate()
                .map { try JSONDecoder().decode(OutstandingOrder.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
    }
    
    private func addOutstandingOrderConstructedItems(outstandingOrderID: OutstandingOrder.ID, data: AddOutstandingOrderConstructedItemsRequestData, token: JWT? = nil) -> Promise<OutstandingOrder> {
        do {
            return try httpClient.send(apiURLRequestFactory.makeAddOutstandingOrderConstructedItemsRequest(id: outstandingOrderID, data: data, token: token)).validate()
                .map { try JSONDecoder().decode(OutstandingOrder.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
    }
    
    private func getTokenUser(token: JWT) -> Promise<User> {
        return httpClient.send(apiURLRequestFactory.makeGetTokenUserRequest(token: token)).validate()
            .map { try JSONDecoder().decode(User.self, from: $0.data) }
    }
    
    // MARK: - Section Model Methods
    private func makeCategoryCollectionViewSectionModels() -> [UICollectionViewSectionModel] {
        var sectionModels = [UICollectionViewSectionModel]()
        if let categoriesModel = categoriesCollectionViewSectionModel {
            sectionModels.append(categoriesModel)
        }
        return sectionModels
    }
    
    private func makeCategoriesTableViewSectionModel(categories: [Category]) -> UICollectionViewSectionModel {
        return UICollectionViewSectionModel(cellViewModels: categories.map(makeCategoryRoundedTextCollectionViewCellViewModel))
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
