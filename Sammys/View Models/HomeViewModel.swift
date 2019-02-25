//
//  HomeViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/21/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

class HomeViewModel {
    private typealias CategoriesDownload = Download<URLRequest, [Category]>
    
    private let httpClient: HTTPClient
    private let apiURLRequestFactory = APIURLRequestFactory()
    
    private var categoriesDownload: CategoriesDownload? {
        didSet {
            guard let download = categoriesDownload else { return }
            handleCategoriesDownload(download)
        }
    }
    
    var categoryImageTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]()
    var categoriesDownloadErrorHandler: ((Error) -> Void)?
    
    // MARK: - Dynamic Properties
    let tableViewSectionModels = Dynamic([UITableViewSectionModel]())
    let isCategoriesDownloading = Dynamic(false)
    
    init(httpClient: HTTPClient = URLSessionHTTPClient()) {
        self.httpClient = httpClient
    }
    
    func beginCategoriesDownload() {
        categoriesDownload = makeCategoriesDownload()
    }
    
    private func handleCategoriesDownload(_ download: CategoriesDownload) {
        switch download {
        case .willDownload(let request):
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
                tableViewSectionModels.value.append(UITableViewSectionModel(cellViewModels: categories.map(makeCategoryImageTableViewCellViewModel)))
            case .failure(let error): categoriesDownloadErrorHandler?(error)
            }
        }
    }
    
    private func makeCategoriesDownload() -> CategoriesDownload {
        return .willDownload(apiURLRequestFactory.makeGetCategoriesRequest(queryItems: [URLQueryItem(name: "isRoot", value: "true")]))
    }
    
    private func makeCategoryImageTableViewCellViewModel(category: Category) -> CategoryImageTableViewCellViewModel {
        return CategoryImageTableViewCellViewModel(
            identifier: HomeViewController.CellIdentifier.imageCell.rawValue,
            height: 100,
            actions: categoryImageTableViewCellViewModelActions,
            configurationData: .init(text: category.name),
            selectionData: .init(id: category.id)
        )
    }
}

extension HomeViewModel {
    struct CategoryImageTableViewCellViewModel: UITableViewCellViewModel {
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
