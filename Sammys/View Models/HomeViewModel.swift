//
//  HomeViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/21/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

class HomeViewModel {
    private typealias GetCategoriesDownload = Download<URLRequest, Promise<[Category]>, [Category]>
    
    var httpClient: HTTPClient
    private let apiURLRequestFactory = APIURLRequestFactory()
    
    // MARK: - Section Model Properties
    private var _tableViewSectionModels: [UITableViewSectionModel] {
        var sectionModels = [UITableViewSectionModel]()
        if let categoriesSectionModel = categoriesTableViewSectionModel { sectionModels.append(categoriesSectionModel) }
        return sectionModels
    }
    private var categoriesTableViewSectionModel: UITableViewSectionModel?
    
    // MARK: - View Settable Properties
    var categoryImageTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]()
    var errorHandler: ((Error) -> Void)?
    
    // MARK: - Dynamic Properties
    let tableViewSectionModels = Dynamic([UITableViewSectionModel]())
    let isCategoriesDownloading = Dynamic(false)
    
    private struct Constants {
        static let categoryImageTableViewCellViewModelHeight: Double = 100
    }
    
    init(httpClient: HTTPClient = URLSessionHTTPClient()) {
        self.httpClient = httpClient
    }
    
    // MARK: - Download Methods
    func beginDownloads() {
        bindAndRunStateUpdate(to: makeGetCategoriesDownload())
    }
    
    private func makeGetCategoriesDownload() -> GetCategoriesDownload {
        let queryItems = [URLQueryItem(name: "isRoot", value: String(true))]
        return GetCategoriesDownload(source: apiURLRequestFactory.makeGetCategoriesRequest(queryItems: queryItems))
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
                    self.categoriesTableViewSectionModel = UITableViewSectionModel(
                        cellViewModels: categories.map(self.makeCategoryImageTableViewCellViewModel)
                    )
                    self.tableViewSectionModels.value = self._tableViewSectionModels
                case .failure(let error): self.errorHandler?(error)
                }
            }
        }
    }
    
    // MARK: - Cell View Model Methods
    private func makeCategoryImageTableViewCellViewModel(category: Category) -> CategoryImageTableViewCellViewModel {
        return CategoryImageTableViewCellViewModel(
            identifier: HomeViewController.CellIdentifier.imageCell.rawValue,
            height: Constants.categoryImageTableViewCellViewModelHeight,
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
