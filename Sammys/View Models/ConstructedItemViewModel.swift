//
//  ConstructedItemViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/25/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

class ConstructedItemViewModel {
    private typealias CategoriesDownload = Download<URLRequest, [Category]>
    
    private let httpClient: HTTPClient
    private let apiURLRequestFactory = APIURLRequestFactory()
    
    private var categoriesDownload: CategoriesDownload? {
        didSet {
            guard let download = categoriesDownload else { return }
            handleCategoriesDownload(download)
        }
    }
    
    // MARK: - View Settable Properties
    var categoryID: Category.ID?
    var categoryRoundedTextCollectionViewCellViewModelActions = [UICollectionViewCellAction : UICollectionViewCellActionHandler]()
    var categoryRoundedTextCollectionViewCellViewModelSize: ((CategoryRoundedTextCollectionViewCellViewModel) -> (width: Double, height: Double))?
    var errorHandler: ((Error) -> Void)?
    
    // MARK: - Dynamic Properties
    let selectedCategoryID: Dynamic<Category.ID?> = Dynamic(nil)
    let categoryCollectionViewSectionModels = Dynamic([UICollectionViewSectionModel]())
    let isCategoriesDownloading = Dynamic(false)
    
    init(httpClient: HTTPClient = URLSessionHTTPClient()) {
        self.httpClient = httpClient
    }
    
    func beginDownloads() {
        categoriesDownload = makeCategoriesDownload()
    }
    
    private func handleCategoriesDownload(_ download: CategoriesDownload) {
        switch download {
        case .willDownload(let request):
            categoriesDownload = .downloading
            httpClient.send(request)
                .map { try JSONDecoder().decode([Category].self, from: $0.data) }
                .get { self.categoriesDownload = .completed(.success($0)) }
                .catch { self.categoriesDownload = .completed(.failure($0)) }
        case .downloading:
            isCategoriesDownloading.value = true
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
    
    private func makeCategoriesDownload() -> CategoriesDownload {
        return .willDownload(apiURLRequestFactory.makeGetSubcategoriesRequest(parentCategoryID: categoryID ?? preconditionFailure()))
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
