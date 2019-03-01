//
//  HomeViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/21/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

class HomeViewModel {
    private typealias CategoriesDownload = DownloadState<URLRequest, Void, [Category]>
    
    var httpClient: HTTPClient = URLSessionHTTPClient()
    private let apiURLRequestFactory = APIURLRequestFactory()
    
    private var categoriesDownload: CategoriesDownload? {
        didSet {
            guard let download = categoriesDownload else { return }
            handleCategoriesDownload(download)
        }
    }
    private var categoriesTableViewSectionModel: UITableViewSectionModel?
    private var _tableViewSectionModels: [UITableViewSectionModel] {
        var sectionModels = [UITableViewSectionModel]()
        if let categoriesSectionModel = categoriesTableViewSectionModel { sectionModels.append(categoriesSectionModel) }
        return sectionModels
    }
    
    // MARK: - View Settable Properties
    var categoryImageTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]()
    var errorHandler: ((Error) -> Void)?
    
    // MARK: - Dynamic Properties
    let tableViewSectionModels = Dynamic([UITableViewSectionModel]())
    let isCategoriesDownloading = Dynamic(false)
    
    private struct Constants {
        static let categoryImageTableViewCellViewModel: Double = 100
    }
    
    func beginDownloads() {
        categoriesDownload = makeCategoriesDownload()
    }
    
    private func handleCategoriesDownload(_ download: CategoriesDownload) {
        switch download {
        case .willDownload(let request):
            categoriesDownload = .downloading(())
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
                categoriesTableViewSectionModel = UITableViewSectionModel(
                    cellViewModels: categories.map(makeCategoryImageTableViewCellViewModel)
                )
                tableViewSectionModels.value = _tableViewSectionModels
            case .failure(let error): errorHandler?(error)
            }
        }
    }
    
    private func makeCategoriesDownload() -> CategoriesDownload {
        return .willDownload(apiURLRequestFactory.makeGetCategoriesRequest(queryItems: [URLQueryItem(name: "isRoot", value: "true")]))
    }
    
    private func makeCategoryImageTableViewCellViewModel(category: Category) -> CategoryImageTableViewCellViewModel {
        return CategoryImageTableViewCellViewModel(
            identifier: HomeViewController.CellIdentifier.imageCell.rawValue,
            height: Constants.categoryImageTableViewCellViewModel,
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
