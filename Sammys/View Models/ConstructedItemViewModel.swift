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
    
    /// Allowed to be `nil`. Use `beginUserIDDownload()` to attempt to set.
    /// Must be set to the constructed item's user's ID before beginning downloads.
    /// If set and verifiable, calling `beginCreateConstructedItemDownload()`
    /// will set the constructed item's user to the one specified.
    var userID: User.ID?
    
    var categoryRoundedTextCollectionViewCellViewModelActions = [UICollectionViewCellAction: UICollectionViewCellActionHandler]()
    
    var errorHandler: ((Error) -> Void) = { _ in }
    
    // MARK: - View Gettable Properties
    var isUserSignedIn: Bool { return userAuthManager.isUserSignedIn }
    
    // MARK: - Dynamic Properties
    /// The selected category ID to present its items.
    let selectedCategoryID: Dynamic<Category.ID?> = Dynamic(nil)
    let selectedCategoryName: Dynamic<String?> = Dynamic(nil)
    
    let totalPriceText: Dynamic<String?> = Dynamic(nil)
    let isFavorite = Dynamic(false)
    let isOutstandingOrderAddable = Dynamic(false)
    
    private(set) lazy var categoryCollectionViewSectionModels = Dynamic(makeCategoryCollectionViewSectionModels())
    
    let selectedCategoryItemIDs = Dynamic([Item.CategoryItemID]())
    
    // MARK: - Section Model Properties
    private var categoriesCollectionViewSectionModel: UICollectionViewSectionModel? {
        didSet { updateCategoryCollectionViewSectionModels() }
    }
    
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
    private func setUp(for categories: [Category]) {
        selectedCategoryID.value = categories.first?.id
        selectedCategoryName.value = categories.first?.name
        categoriesCollectionViewSectionModel = makeCategoriesTableViewSectionModel(categories: categories)
    }
    
    private func setUp(for constructedItem: ConstructedItem) {
        if let totalPrice = constructedItem.totalPrice {
            if totalPrice > 0 {
                totalPriceText.value = String(totalPrice.toUSDUnits().toPriceString())
            } else { totalPriceText.value = nil }
        }
        
        isFavorite.value = constructedItem.isFavorite
        isOutstandingOrderAddable.value = constructedItem.isRequirementsSatisfied ?? false
    }
    
    private func setUp(for outstandingOrderID: OutstandingOrder.ID) {
        self.outstandingOrderID = outstandingOrderID
        keyValueStore.set(outstandingOrderID.uuidString, forKey: KeyValueStoreKeys.currentOutstandingOrderID)
    }
    
    private func updateCategoryCollectionViewSectionModels() {
        categoryCollectionViewSectionModels.value = makeCategoryCollectionViewSectionModels()
    }
    
    // MARK: - Download Methods
    func beginDownloads() {
        beginCategoriesDownload()
            .catch { self.errorHandler($0) }
    }
    
    func beginCreateConstructedItemDownload() {
        makeCreateConstructedItemDownload()
            .get { self.constructedItemID = $0.id }
            .done(setUp)
            .catch(errorHandler)
    }
    
    func beginSelectedCategoryItemIDsDownload() {
        makeSelectedCategoryItemIDsDownload().done { items in
            self.selectedCategoryItemIDs.value =  items.compactMap { $0.categoryItemID }
        }.catch(errorHandler)
    }
    
    func beginAddConstructedItemItemsDownload(categoryItemIDs: [Item.CategoryItemID]) {
        makeAddConstructedItemItemsDownload(categoryItemIDs: categoryItemIDs)
            .done(setUp)
            .catch(errorHandler)
    }
    
    func beginRemoveConstructedItemItemDownload(categoryItemID: Item.CategoryItemID) {
        makeRemoveConstructedItemItemDownload(categoryItemID: categoryItemID)
            .done(setUp)
            .catch(errorHandler)
    }
    
    func beginUpdateConstructedItemDownload(isFavorite: Bool) {
        userAuthManager.getCurrentUserIDToken()
            .then { self.partiallyUpdateConstructedItem(data: .init(isFavorite: isFavorite), token: $0) }
            .done(setUp)
            .catch(errorHandler)
    }
    
    func beginUpdateConstructedItemUserDownload() {
        userAuthManager.getCurrentUserIDToken()
            .then { self.partiallyUpdateConstructedItem(data: .init(userID: self.userID ?? preconditionFailure()), token: $0) }
            .catch(errorHandler)
    }
    
    func beginAddToOutstandingOrderDownload(successHandler: @escaping (() -> Void) = {}) {
        makeAddToOutstandingOrderDownload()
            .done(successHandler)
            .catch(errorHandler)
    }
    
    func beginUserIDDownload(successHandler: @escaping (() -> Void) = {}) {
        userAuthManager.getCurrentUserIDToken()
            .then { self.getTokenUser(token: $0) }
            .get { self.userID = $0.id }.asVoid()
            .done(successHandler)
            .catch(errorHandler)
    }
    
    private func beginCategoriesDownload() -> Promise<Void> {
        return getCategories().done(setUp)
    }
    
    private func beginOutstandingOrderIDDownload(token: JWT? = nil) -> Promise<Void> {
        return makeOutstandingOrderIDDownload(token: token).done(setUp)
    }
    
    private func beginAddToOutstandingOrderDownload(token: JWT? = nil) -> Promise<Void> {
        return addOutstandingOrderConstructedItems(outstandingOrderID: outstandingOrderID ?? preconditionFailure(), data: .init(ids: [self.constructedItemID ?? preconditionFailure()]), token: token).asVoid()
    }
    
    private func makeCreateConstructedItemDownload() -> Promise<ConstructedItem> {
        if let userID = userID {
            return userAuthManager.getCurrentUserIDToken().then { token in
                self.createConstructedItem(data: .init(categoryID: self.categoryID ?? preconditionFailure(), userID: userID), token: token)
            }
        } else { return createConstructedItem(data: .init(categoryID: categoryID ?? preconditionFailure())) }
    }
    
    private func makeSelectedCategoryItemIDsDownload() -> Promise<[Item]> {
        if userID != nil {
            return userAuthManager.getCurrentUserIDToken()
                .then { self.getConstructedItemItems(token: $0) }
        } else { return getConstructedItemItems() }
    }
    
    private func makeAddConstructedItemItemsDownload(categoryItemIDs: [Item.CategoryItemID]) -> Promise<ConstructedItem> {
        if userID != nil {
            return userAuthManager.getCurrentUserIDToken().then { token in
                self.addConstructedItemItems(data: .init(categoryItemIDs: categoryItemIDs), token: token)
            }
        } else { return addConstructedItemItems(data: .init(categoryItemIDs: categoryItemIDs)) }
    }
    
    private func makeRemoveConstructedItemItemDownload(categoryItemID: Item.CategoryItemID) -> Promise<ConstructedItem> {
        if userID != nil {
            return userAuthManager.getCurrentUserIDToken().then { token in
                self.removeConstructedItemItem(categoryItemID: categoryItemID, token: token)
            }
        } else { return removeConstructedItemItem(categoryItemID: categoryItemID) }
    }
    
    private func makeOutstandingOrderIDDownload(token: JWT? = nil) -> Promise<OutstandingOrder.ID> {
        if let storedOutstandingOrderIDString = keyValueStore.value(of: String.self, forKey: KeyValueStoreKeys.currentOutstandingOrderID),
            let id = OutstandingOrder.ID(uuidString: storedOutstandingOrderIDString) {
            return Promise { $0.fulfill((id)) }
        } else if userID != nil {
            guard let token = token else { preconditionFailure() }
            return getUserOutstandingOrders(token: token).then { outstandingOrders -> Promise<OutstandingOrder> in
                if let outstandingOrder = outstandingOrders.first { return Promise { $0.fulfill(outstandingOrder) } }
                else { return self.createOutstandingOrder(data: .init(userID: self.userID), token: token) }
            }.map { $0.id }
        } else { return createOutstandingOrder().map { $0.id } }
    }
    
    private func makeOutstandingOrderIDAndAddToOutstandingOrderDownload(token: JWT? = nil) -> Promise<Void> {
        if outstandingOrderID != nil {
            return beginAddToOutstandingOrderDownload(token: token)
        } else {
            return beginOutstandingOrderIDDownload(token: token)
                .then { self.beginAddToOutstandingOrderDownload(token: token) }
        }
    }
    
    func makeAddToOutstandingOrderDownload() -> Promise<Void> {
        if userID != nil {
            return userAuthManager.getCurrentUserIDToken()
                .then { self.makeOutstandingOrderIDAndAddToOutstandingOrderDownload(token: $0) }
        } else { return makeOutstandingOrderIDAndAddToOutstandingOrderDownload() }
    }
    
    private func getCategories() -> Promise<[Category]> {
        return httpClient.send(apiURLRequestFactory.makeGetSubcategoriesRequest(parentCategoryID: categoryID ?? preconditionFailure()))
            .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode([Category].self, from: $0.data) }
    }
    
    private func getConstructedItemItems(token: JWT? = nil) -> Promise<[Item]> {
        return httpClient.send(apiURLRequestFactory.makeGetConstructedItemItems(id: constructedItemID ?? preconditionFailure(), queryData: .init(categoryID: selectedCategoryID.value), token: token)).validate()
            .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode([Item].self, from: $0.data) }
    }
    
    private func createConstructedItem(data: CreateConstructedItemRequestData, token: JWT? = nil) -> Promise<ConstructedItem> {
        do {
            return try httpClient.send(apiURLRequestFactory.makeCreateConstructedItemRequest(data: data, token: token)).validate()
                .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode(ConstructedItem.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
    }
    
    private func addConstructedItemItems(data: AddConstructedItemItemsRequestData, token: JWT? = nil) -> Promise<ConstructedItem> {
        do {
            return try httpClient.send(apiURLRequestFactory.makeAddConstructedItemItemsRequest(id: constructedItemID ?? preconditionFailure(), data: data, token: token)).validate()
                .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode(ConstructedItem.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
    }
    
    private func removeConstructedItemItem(categoryItemID: Item.CategoryItemID, token: JWT? = nil) -> Promise<ConstructedItem> {
        return httpClient.send(apiURLRequestFactory.makeRemoveConstructedItemItemsRequest(constructedItemID: constructedItemID ?? preconditionFailure(), categoryItemID: categoryItemID, token: token)).validate()
            .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode(ConstructedItem.self, from: $0.data) }
    }
    
    private func partiallyUpdateConstructedItem(data: PartiallyUpdateConstructedItemRequestData, token: JWT? = nil) -> Promise<ConstructedItem> {
        do {
            return try  httpClient.send(apiURLRequestFactory.makePartiallyUpdateConstructedItemRequest(id: constructedItemID ?? preconditionFailure(), data: data, token: token)).validate()
            .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode(ConstructedItem.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
    }
    
    private func getUserOutstandingOrders(token: JWT) -> Promise<[OutstandingOrder]> {
        return httpClient.send(apiURLRequestFactory.makeGetUserOutstandingOrdersRequest(id: userID ?? preconditionFailure(), token: token)).validate()
            .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode([OutstandingOrder].self, from: $0.data) }
    }
    
    private func createOutstandingOrder(data: CreateOutstandingOrderRequestData = .init(), token: JWT? = nil) -> Promise<OutstandingOrder> {
        do {
            return try httpClient.send(apiURLRequestFactory.makeCreateOutstandingOrderRequest(data: data, token: token)).validate()
                .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode(OutstandingOrder.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
    }
    
    private func addOutstandingOrderConstructedItems(outstandingOrderID: OutstandingOrder.ID, data: AddOutstandingOrderConstructedItemsRequestData, token: JWT? = nil) -> Promise<OutstandingOrder> {
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
    private func makeCategoriesTableViewSectionModel(categories: [Category]) -> UICollectionViewSectionModel {
        return UICollectionViewSectionModel(cellViewModels: categories.map(makeCategoryRoundedTextCollectionViewCellViewModel))
    }
    
    private func makeCategoryCollectionViewSectionModels() -> [UICollectionViewSectionModel] {
        var sectionModels = [UICollectionViewSectionModel]()
        if let categoriesModel = categoriesCollectionViewSectionModel {
            sectionModels.append(categoriesModel)
        }
        return sectionModels
    }
    
    // MARK: - Cell View Model Methods
    private func makeCategoryRoundedTextCollectionViewCellViewModel(category: Category) -> CategoryRoundedTextCollectionViewCellViewModel {
        return CategoryRoundedTextCollectionViewCellViewModel(
            identifier: CellIdentifier.roundedTextCollectionViewCell.rawValue,
            actions: categoryRoundedTextCollectionViewCellViewModelActions,
            configurationData: .init(text: category.name),
            selectionData: .init(categoryID: category.id, categoryName: category.name)
        )
    }
}

extension ConstructedItemViewModel {
    struct CategoryRoundedTextCollectionViewCellViewModel: UICollectionViewCellViewModel {
        let identifier: String
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
