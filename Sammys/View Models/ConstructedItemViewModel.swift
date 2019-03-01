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
    typealias CategoriesDownload = DownloadState<URLRequest, Promise<[Category]>, [Category]>
    typealias ConstructedItemDownload = DownloadState<URLRequest, Promise<ConstructedItem>, ConstructedItem>
    typealias AddConstructedItemItemsDownload = Download<URLRequest, Promise<ConstructedItem>, ConstructedItem>
    
    var httpClient: HTTPClient = URLSessionHTTPClient()
    private let apiURLRequestFactory = APIURLRequestFactory()
    
    private(set) var categoriesDownload: CategoriesDownload? {
        didSet {
            guard let download = categoriesDownload else { return }
            handleCategoriesDownload(download)
        }
    }
    
    private(set) var constructedItemDownload: ConstructedItemDownload? {
        didSet {  }
    }
    
    private(set) var addConstructedItemItemsDownloadQueue = Queue<AddConstructedItemItemsDownload>() {
        didSet {
            if let download = addConstructedItemItemsDownloadQueue.dequeue() {
                handleNewAddConstructedItemItemsDownload(download)
            }
        }
    }
    
    // MARK: - View Settable Properties
    var constructedItemID: UUID?
    var categoryID: Category.ID?
    var categoryRoundedTextCollectionViewCellViewModelActions = [UICollectionViewCellAction : UICollectionViewCellActionHandler]()
    var categoryRoundedTextCollectionViewCellViewModelSize: ((CategoryRoundedTextCollectionViewCellViewModel) -> (width: Double, height: Double))?
    var errorHandler: ((Error) -> Void)?
    
    // MARK: - Dynamic Properties
    let selectedCategoryID: Dynamic<Category.ID?> = Dynamic(nil)
    let categoryCollectionViewSectionModels = Dynamic([UICollectionViewSectionModel]())
    let isCategoriesDownloading = Dynamic(false)
    
    func beginDownloads() {
        categoriesDownload = makeCategoriesDownload()
    }
    
    func beginAddConstructedItemItemsDownload(categoryItemIDs: [UUID]) {
        do { addConstructedItemItemsDownloadQueue.enqueue(try makeAddConstructedItemItemsDownload(categoryItemIDs: categoryItemIDs)) }
        catch {  }
    }
    
    private func handleCategoriesDownload(_ download: CategoriesDownload) {
        switch download {
        case .willDownload(let request):
            categoriesDownload = .downloading(httpClient.send(request)
                .map { try JSONDecoder().decode([Category].self, from: $0.data) })
        case .downloading(let promise):
            isCategoriesDownloading.value = true
            promise.get { self.categoriesDownload = .completed(.success($0)) }
                .catch { self.categoriesDownload = .completed(.failure($0)) }
        case .completed(let result):
            isCategoriesDownloading.value = false
            switch result {
            case .success(let categories):
                selectedCategoryID.value = categories.first?.id
                categoryCollectionViewSectionModels.value = [UICollectionViewSectionModel(cellViewModels: categories.map(makeCategoryRoundedTextCollectionViewCellViewModel))]
            case .failure(let error): errorHandler?(error)
            }
        }
    }
    
    private func handleNewAddConstructedItemItemsDownload(_ download: AddConstructedItemItemsDownload) {
        download.state.bindAndRun { state in
            switch state {
            case .willDownload(let request):
                download.state.value = .downloading(self.httpClient.send(request)
                    .map { try JSONDecoder().decode(ConstructedItem.self, from: $0.data) })
            case .downloading(let promise):
                promise.get { download.state.value = .completed(.success($0)) }
                    .catch { download.state.value = .completed(.failure($0)) }
            case .completed(let result):
                switch result {
                case .success(let constructedItem): break
                case .failure(let error): break
                }
            }
        }
    }
    
    private func makeCategoriesDownload() -> CategoriesDownload {
        return .willDownload(apiURLRequestFactory.makeGetSubcategoriesRequest(parentCategoryID: categoryID ?? preconditionFailure()))
    }
    
    private func makeAddConstructedItemItemsDownload(categoryItemIDs: [UUID]) throws -> AddConstructedItemItemsDownload {
        return AddConstructedItemItemsDownload(source: try apiURLRequestFactory.makeAddConstructedItemItemsRequest(id: constructedItemID ?? preconditionFailure(), data: AddConstructedItemItemsData(categoryItemIDs: categoryItemIDs)))
    }
    
    private func makeCategoryRoundedTextCollectionViewCellViewModel(category: Category) -> CategoryRoundedTextCollectionViewCellViewModel {
        var cellViewModel = CategoryRoundedTextCollectionViewCellViewModel(
            identifier: ConstructedItemViewController.CellIdentifier.roundedTextCell.rawValue,
            size: nil,
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
        var size: (width: Double, height: Double)?
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
