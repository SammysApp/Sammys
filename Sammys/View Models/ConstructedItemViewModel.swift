//
//  ConstructedItemViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/25/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

class ConstructedItemViewModel {
    private let apiURLRequestFactory = APIURLRequestFactory()
    
    // MARK: - Dependencies
    var httpClient: HTTPClient
    var keyValueStore: KeyValueStore
    
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
    
    var categoryRoundedTextCollectionViewCellViewModelActions = [UICollectionViewCellAction: UICollectionViewCellActionHandler]()
    var categoryRoundedTextCollectionViewCellViewModelSize: ((CategoryRoundedTextCollectionViewCellViewModel) -> (width: Double, height: Double))?
    var errorHandler: ((Error) -> Void)?
    
    // MARK: - Dynamic Properties
    /// The selected category ID to present its items.
    let selectedCategoryID: Dynamic<Category.ID?> = Dynamic(nil)
    let categoryCollectionViewSectionModels = Dynamic([UICollectionViewSectionModel]())
    let isCategoriesDownloading = Dynamic(false)
    let totalPriceText: Dynamic<String?> = Dynamic(nil)
    
    init(httpClient: HTTPClient = URLSession.shared,
         keyValueStore: KeyValueStore = UserDefaults.standard) {
        self.httpClient = httpClient
        self.keyValueStore = keyValueStore
    }
    
    // MARK: - Download Methods
    func beginDownloads() {
        firstly { beginCategoriesDownload() }
            .catch { self.errorHandler?($0) }
    }
    
    func beginCreateConstructedItemDownload() {
        createConstructedItem()
            .done { self.constructedItemID = $0.id }
            .catch { self.errorHandler?($0) }
    }
    
    func beginAddConstructedItemItemsDownload(categoryItemIDs: [Item.CategoryItemID]) {
        addConstructedItemItems(data: .init(categoryItemIDs: categoryItemIDs)).done { constructedItem in
            if let totalPrice = constructedItem.totalPrice {
                if totalPrice > 0 { self.totalPriceText.value = String(totalPrice) }
                else { self.totalPriceText.value = nil }
            }
        }.catch { self.errorHandler?($0) }
    }
    
    func beginRemoveConstructedItemItemsDownload(categoryItemID: Item.CategoryItemID) {
        removeConstructedItemItem(categoryItemID: categoryItemID).done { constructedItem in
            if let totalPrice = constructedItem.totalPrice {
                if totalPrice > 0 { self.totalPriceText.value = String(totalPrice) }
                else { self.totalPriceText.value = nil }
            }
        }.catch { self.errorHandler?($0) }
    }
    
    func beginAddToOutstandingOrderDownload(successfulCompletionHandler: (() -> Void)? = nil) {
        let outstandingOrderPromise: Promise<Void>
        if outstandingOrderID != nil {
            outstandingOrderPromise = _beginAddToOutstandingOrderDownload()
        } else {
            outstandingOrderPromise = beginOutstandingOrderDownload()
                .then { self._beginAddToOutstandingOrderDownload() }
        }
        outstandingOrderPromise.done { successfulCompletionHandler?() }
            .catch { self.errorHandler?($0) }
    }
    
    private func beginCategoriesDownload() -> Promise<Void> {
        isCategoriesDownloading.value = true
        return getCategories().done { categories in
            self.selectedCategoryID.value = categories.first?.id
            self.categoryCollectionViewSectionModels.value = self.makeCategoryCollectionViewSectionModels(categories: categories)
        }.ensure { self.isCategoriesDownloading.value = false }
    }
    
    private func beginOutstandingOrderDownload() -> Promise<Void> {
        if let storedOutstandingOrderIDString = keyValueStore.value(of: String.self, forKey: KeyValueStoreKeys.outstandingOrder) {
            outstandingOrderID = OutstandingOrder.ID(uuidString: storedOutstandingOrderIDString)
            return Promise { $0.fulfill(()) }
        } else {
            return createOutstandingOrder(data: .init()).done {
                self.outstandingOrderID = $0.id
                self.keyValueStore.set($0.id.uuidString, forKey: KeyValueStoreKeys.outstandingOrder)
            }
        }
    }
    
    private func _beginAddToOutstandingOrderDownload() -> Promise<Void> {
        return addOutstandingOrderConstructedItems(
            outstandingOrderID: outstandingOrderID ?? preconditionFailure(), data: .init(ids: [self.constructedItemID ?? preconditionFailure()])
        ).asVoid()
    }
    
    private func getCategories() -> Promise<[Category]> {
        return httpClient.send(apiURLRequestFactory.makeGetSubcategoriesRequest(parentCategoryID: categoryID ?? preconditionFailure()))
            .map { try JSONDecoder().decode([Category].self, from: $0.data) }
    }
    
    private func createConstructedItem() -> Promise<ConstructedItem> {
        do {
            return try httpClient.send(apiURLRequestFactory.makeCreateConstructedItemRequest(data: .init(categoryID: categoryID ?? preconditionFailure()))).validate()
                .map { try JSONDecoder().decode(ConstructedItem.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
    }
    
    private func addConstructedItemItems(data: AddConstructedItemItemsData) -> Promise<ConstructedItem> {
        do {
            return try httpClient.send(apiURLRequestFactory.makeAddConstructedItemItemsRequest(id: constructedItemID ?? preconditionFailure(), data: data)).validate()
                .map { try JSONDecoder().decode(ConstructedItem.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
    }
    
    private func removeConstructedItemItem(categoryItemID: Item.CategoryItemID) -> Promise<ConstructedItem> {
        return httpClient.send(apiURLRequestFactory.makeRemoveConstructedItemItemsRequest(
            constructedItemID: constructedItemID ?? preconditionFailure(),
            categoryItemID: categoryItemID)
        ).validate().map { try JSONDecoder().decode(ConstructedItem.self, from: $0.data) }
    }
    
    private func createOutstandingOrder(data: CreateOutstandingOrderData) -> Promise<OutstandingOrder> {
        do {
            return try httpClient.send(apiURLRequestFactory.makeCreateOutstandingOrderRequest(data: data))
                .map { try JSONDecoder().decode(OutstandingOrder.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
    }
    
    private func addOutstandingOrderConstructedItems(outstandingOrderID: OutstandingOrder.ID, data: AddOutstandingOrderConstructedItemsData) -> Promise<OutstandingOrder> {
        do {
            return try httpClient.send(apiURLRequestFactory.makeAddOutstandingOrderConstructedItemsRequest(id: outstandingOrderID, data: data))
                .map { try JSONDecoder().decode(OutstandingOrder.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
    }
    
    // MARK: - Section Model Methods
    private func makeCategoryCollectionViewSectionModels(categories: [Category]) -> [UICollectionViewSectionModel] {
        return [UICollectionViewSectionModel(cellViewModels: categories.map(makeCategoryRoundedTextCollectionViewCellViewModel))]
    }
    
    // MARK: - Cell View Model Methods
    private func makeCategoryRoundedTextCollectionViewCellViewModel(category: Category) -> CategoryRoundedTextCollectionViewCellViewModel {
        var cellViewModel = CategoryRoundedTextCollectionViewCellViewModel(
            identifier: ConstructedItemViewController.CellIdentifier.roundedTextCollectionViewCell.rawValue,
            size: (0, 0),
            actions: categoryRoundedTextCollectionViewCellViewModelActions,
            configurationData: .init(text: category.name),
            selectionData: .init(categoryID: category.id)
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
        }
    }
}
