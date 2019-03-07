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
    
    // MARK: - Download Properties
    private var activeAddConstructedItemItemsDownloadPromises = [UUID: Promise<ConstructedItem>]()
    
    // MARK: - View Settable Properties
    /// The category ID of the presented constructed item. Required to be non-`nil`.
    /// Used to get the available categories of the constructed item,
    /// the subcategories of this category.
    var categoryID: Category.ID?
    /// The presented constructed item's ID. Required to be non-`nil`.
    /// Call `beginCreateConstructedItemDownload()` to create a new one.
    var constructedItemID: UUID?
    
    var categoryRoundedTextCollectionViewCellViewModelActions = [UICollectionViewCellAction : UICollectionViewCellActionHandler]()
    var categoryRoundedTextCollectionViewCellViewModelSize: ((CategoryRoundedTextCollectionViewCellViewModel) -> (width: Double, height: Double))?
    var errorHandler: ((Error) -> Void)?
    
    // MARK: - Dynamic Properties
    /// The selected category ID to present its items.
    let selectedCategoryID: Dynamic<Category.ID?> = Dynamic(nil)
    let categoryCollectionViewSectionModels = Dynamic([UICollectionViewSectionModel]())
    let isCategoriesDownloading = Dynamic(false)
    let totalPriceText: Dynamic<String?> = Dynamic(nil)
    
    init(httpClient: HTTPClient = URLSessionHTTPClient(),
         keyValueStore: KeyValueStore = UserDefaults.standard) {
        self.httpClient = httpClient
        self.keyValueStore = keyValueStore
    }
    
    // MARK: - Download Methods
    func beginDownloads() {
        beginCategoriesDownload()
    }
    
    private func beginCategoriesDownload() {
        isCategoriesDownloading.value = true
        getCategories()
            .done { categories in
                self.selectedCategoryID.value = categories.first?.id
                self.categoryCollectionViewSectionModels.value = self.makeCategoryCollectionViewSectionModels(categories: categories)
            }.ensure { self.isCategoriesDownloading.value = false }
            .catch { self.errorHandler?($0) }
    }
    
    func beginCreateConstructedItemDownload() {
        createConstructedItem()
            .done { self.constructedItemID = $0.id }
            .catch { self.errorHandler?($0) }
    }
    
    func beginAddConstructedItemItemsDownload(categoryItemIDs: [UUID]) {
        let promiseID = UUID()
        let promise = addConstructedItemItems(categoryItemIDs: categoryItemIDs)
        activeAddConstructedItemItemsDownloadPromises[promiseID] = promise
        // FIXME: Might not happen in order. Last one can be earlier promise. Consider queue.
        promise.ensure { self.activeAddConstructedItemItemsDownloadPromises[promiseID] = nil }
            .done { constructedItem in
                if self.activeAddConstructedItemItemsDownloadPromises.isEmpty {
                    if let totalPrice = constructedItem.totalPrice {
                        if totalPrice > 0 { self.totalPriceText.value = String(totalPrice) }
                        else { self.totalPriceText.value = nil }
                    }
                }
            }.catch { self.errorHandler?($0) }
    }
    
    func beginOutstandingOrdersDownload(successfulCompletionHandler: @escaping ([OutstandingOrder.ID]) -> Void) {
        if let storedOutstandingOrders = keyValueStore.array(of: OutstandingOrder.ID.self, forKey: KeyValueStoreKeys.outstandingOrders) {
            successfulCompletionHandler(storedOutstandingOrders)
        } else {
            createOutstandingOrder()
                .done {
                    let ids = [$0.id]
                    self.keyValueStore.set(ids, forKey: KeyValueStoreKeys.outstandingOrders)
                    successfulCompletionHandler(ids)
                }.catch { self.errorHandler?($0) }
        }
    }
    
    func beginAddToOutstandingOrderDownload(outstandingOrderID: OutstandingOrder.ID, successfulCompletionHandler: (() -> Void)? = nil) {
        addOutstandingOrderConstructedItems(outstandingOrderID: outstandingOrderID, constructedItemIDs: [self.constructedItemID ?? preconditionFailure()]).asVoid()
            .done { successfulCompletionHandler?() }
            .catch { self.errorHandler?($0) }
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
    
    private func addConstructedItemItems(categoryItemIDs: [UUID]) -> Promise<ConstructedItem> {
        do {
            return try httpClient.send(apiURLRequestFactory.makeAddConstructedItemItemsRequest(id: constructedItemID ?? preconditionFailure(), data: .init(categoryItemIDs: categoryItemIDs))).validate()
                .map { try JSONDecoder().decode(ConstructedItem.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
    }
    
    private func createOutstandingOrder() -> Promise<OutstandingOrder> {
        do {
            return try httpClient.send(apiURLRequestFactory.makeCreateOutstandingOrderRequest(data: .init()))
                .map { try JSONDecoder().decode(OutstandingOrder.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
    }
    
    private func addOutstandingOrderConstructedItems(outstandingOrderID: OutstandingOrder.ID, constructedItemIDs: [ConstructedItem.ID]) -> Promise<OutstandingOrder> {
        do {
            return try httpClient.send(apiURLRequestFactory.makeAddOutstandingOrderConstructedItemsRequest(id: outstandingOrderID, data: .init(ids: constructedItemIDs)))
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
            identifier: ConstructedItemViewController.CellIdentifier.roundedTextCell.rawValue,
            // FIXME: Change to enum.
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
        let actions: [UICollectionViewCellAction : UICollectionViewCellActionHandler]
        
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
