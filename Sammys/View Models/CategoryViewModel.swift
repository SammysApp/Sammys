//
//  CategoryViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/24/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

class CategoryViewModel {
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
    var parentCategoryID: Category.ID?
    var categoryTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]()
    var errorHandler: ((Error) -> Void)?
    
    // MARK: - Dynamic Properties
    let tableViewSectionModels = Dynamic([UITableViewSectionModel]())
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
                tableViewSectionModels.value.append(UITableViewSectionModel(cellViewModels: categories.map(makeCategoryTableViewCellViewModel)))
            case .failure(let error): errorHandler?(error)
            }
        }
    }
    
    private func makeCategoriesDownload() -> CategoriesDownload {
        if let id = parentCategoryID {
            return .willDownload(apiURLRequestFactory
                .makeGetSubcategoriesRequest(parentCategoryID: id))
        } else {
            return .willDownload(apiURLRequestFactory.makeGetCategoriesRequest())
        }
    }
    
    private func makeCategoryTableViewCellViewModel(category: Category) -> CategoryTableViewCellViewModel {
        return CategoryTableViewCellViewModel(
            identifier: CategoryViewController.CellIdentifier.cell.rawValue,
            height: 100,
            actions: categoryTableViewCellViewModelActions,
            configurationData: .init(text: category.name),
            selectionData: .init(id: category.id)
        )
    }
}

extension CategoryViewModel {
    struct CategoryTableViewCellViewModel: UITableViewCellViewModel {
        let identifier: String
        let height: Double
        let actions: [UITableViewCellAction: UITableViewCellActionHandler]
        
        let configurationData: ConfigurationData
        let selectionData: SelectionData
        
        struct ConfigurationData {
            let text: String
        }
        
        struct SelectionData {
            let id: Category.ID
        }
    }
}
