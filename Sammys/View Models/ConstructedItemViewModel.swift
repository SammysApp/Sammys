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
    private typealias CreateConstructedItemDownload = Download<URLRequest, Promise<ConstructedItem>, ConstructedItem>
    private typealias GetCategoriesDownload = Download<URLRequest, Promise<[Category]>, [Category]>
    private typealias AddConstructedItemItemsDownload = Download<URLRequest, Promise<ConstructedItem>, ConstructedItem>
    
    var httpClient: HTTPClient
    private let apiURLRequestFactory = APIURLRequestFactory()
    
    // MARK: - Download Properties
    private var activeAddConstructedItemItemsDownloads = [AddConstructedItemItemsDownload]()
    
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
    
    init(httpClient: HTTPClient = URLSessionHTTPClient()) {
        self.httpClient = httpClient
    }
    
    // MARK: - Download Methods
    func beginDownloads() {
        bindAndRunStateUpdate(to: makeGetCategoriesDownload())
    }
    
    func beginCreateConstructedItemDownload() {
        bindAndRunStateUpdate(toCreateConstructedItemDownload: makeCreateConstructedItemDownload())
    }
    
    func beginAddConstructedItemItemsDownload(categoryItemIDs: [UUID]) {
        let download = makeAddConstructedItemItemsDownload(categoryItemIDs: categoryItemIDs)
        bindAndRunStateUpdate(toAddConstructedItemItemsDownload: download)
        activeAddConstructedItemItemsDownloads.append(download)
    }
    
    private func makeGetCategoriesDownload() -> GetCategoriesDownload {
        return GetCategoriesDownload(source: apiURLRequestFactory.makeGetSubcategoriesRequest(parentCategoryID: categoryID ?? preconditionFailure()))
    }
    
    private func makeCreateConstructedItemDownload() -> CreateConstructedItemDownload {
        do { return try CreateConstructedItemDownload(source: apiURLRequestFactory.makeCreateConstructedItemRequest(data: .init(categoryID: categoryID ?? preconditionFailure()))) }
        catch { preconditionFailure(error.localizedDescription) }
    }
    
    private func makeAddConstructedItemItemsDownload(categoryItemIDs: [UUID]) -> AddConstructedItemItemsDownload {
        do { return try AddConstructedItemItemsDownload(source: apiURLRequestFactory.makeAddConstructedItemItemsRequest(id: constructedItemID ?? preconditionFailure(), data: .init(categoryItemIDs: categoryItemIDs))) }
        catch { preconditionFailure(error.localizedDescription) }
    }
    
    private func bindAndRunStateUpdate(to download: GetCategoriesDownload) {
        download.state.bindAndRun { state in
            switch state {
            case .willDownload(let request):
                download.state.value = .downloading(self.httpClient.send(request).validate()
                    .map { try JSONDecoder().decode([Category].self, from: $0.data) })
            case .downloading(let categoriesPromise):
                self.isCategoriesDownloading.value = true
                categoriesPromise.get { download.state.value = .completed(.success($0)) }
                    .catch { download.state.value = .completed(.failure($0)) }
            case .completed(let result):
                self.isCategoriesDownloading.value = false
                switch result {
                case .success(let categories):
                    self.selectedCategoryID.value = categories.first?.id
                    self.categoryCollectionViewSectionModels.value = [UICollectionViewSectionModel(
                        cellViewModels: categories.map(self.makeCategoryRoundedTextCollectionViewCellViewModel)
                    )]
                case .failure(let error): self.errorHandler?(error)
                }
            }
        }
    }
    
    private func bindAndRunStateUpdate(toCreateConstructedItemDownload download: CreateConstructedItemDownload) {
        download.state.bindAndRun { state in
            switch state {
            case .willDownload(let request):
                download.state.value = .downloading(self.httpClient.send(request).validate()
                    .map { try JSONDecoder().decode(ConstructedItem.self, from: $0.data) })
            case .downloading(let constructedItemPromise):
                constructedItemPromise.get { download.state.value = .completed(.success($0)) }
                    .catch { download.state.value = .completed(.failure($0)) }
            case .completed(let result):
                switch result {
                case .success(let constructedItem): self.constructedItemID = constructedItem.id
                case .failure(let error): self.errorHandler?(error)
                }
            }
        }
    }
    
    private func bindAndRunStateUpdate(toAddConstructedItemItemsDownload download: AddConstructedItemItemsDownload) {
        download.state.bindAndRun { state in
            switch state {
            case .willDownload(let request):
                download.state.value = .downloading(self.httpClient.send(request).validate()
                    .map { try JSONDecoder().decode(ConstructedItem.self, from: $0.data) })
            case .downloading(let constructedItemPromise):
                constructedItemPromise.get { download.state.value = .completed(.success($0)) }
                    .catch { download.state.value = .completed(.failure($0)) }
            case .completed(let result):
                self.activeAddConstructedItemItemsDownloads =
                    self.activeAddConstructedItemItemsDownloads.filter { $0.id != download.id }
                switch result {
                case .success(let constructedItem):
                    if self.activeAddConstructedItemItemsDownloads.isEmpty {
                        if let totalPrice = constructedItem.totalPrice {
                            if totalPrice > 0 { self.totalPriceText.value = String(totalPrice) }
                            else { self.totalPriceText.value = nil }
                        }
                    }
                case .failure(let error): self.errorHandler?(error)
                }
            }
        }
    }
    
    // MARK: - Cell View Model Methods
    private func makeCategoryRoundedTextCollectionViewCellViewModel(category: Category) -> CategoryRoundedTextCollectionViewCellViewModel {
        var cellViewModel = CategoryRoundedTextCollectionViewCellViewModel(
            identifier: ConstructedItemViewController.CellIdentifier.roundedTextCell.rawValue,
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
