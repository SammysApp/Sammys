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
    private let apiURLRequestFactory = APIURLRequestFactory()
    
    // MARK: - Dependencies
    var httpClient: HTTPClient
    
    // MARK: - Section Model Properties
    private var categoriesTableViewSectionModel: UITableViewSectionModel? {
        didSet { tableViewSectionModels.value = makeTableViewSectionModels() }
    }
    
    // MARK: - View Settable Properties
    var categoryImageTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]()
    var errorHandler: ((Error) -> Void)?
    
    // MARK: - Dynamic Properties
    let tableViewSectionModels = Dynamic([UITableViewSectionModel]())
    let isCategoriesDownloading = Dynamic(false)
    
    private struct Constants {
        static let categoryImageTableViewCellViewModelHeight: Double = 100
    }
    
    init(httpClient: HTTPClient = URLSession.shared) {
        self.httpClient = httpClient
    }
    
    // MARK: - Download Methods
    func beginDownloads() {
        beginCategoriesDownload()
    }
    
    private func beginCategoriesDownload() {
        isCategoriesDownloading.value = true
        getCategories()
            .done { self.categoriesTableViewSectionModel = self.makeCategoriesTableViewSectionModel(categories: $0) }
            .ensure { self.isCategoriesDownloading.value = false }
            .catch { self.errorHandler?($0) }
    }
    
    private func getCategories() -> Promise<[Category]> {
        let queryItems = [URLQueryItem(name: "isRoot", value: String(true))]
        return httpClient.send(apiURLRequestFactory.makeGetCategoriesRequest(queryItems: queryItems)).validate()
            .map { try JSONDecoder().decode([Category].self, from: $0.data) }
    }
    
    // MARK: - Section Model Methods
    private func makeTableViewSectionModels() -> [UITableViewSectionModel] {
        var sectionModels = [UITableViewSectionModel]()
        if let categoriesModel = categoriesTableViewSectionModel { sectionModels.append(categoriesModel) }
        return sectionModels
    }
    
    private func makeCategoriesTableViewSectionModel(categories: [Category]) -> UITableViewSectionModel {
        return UITableViewSectionModel(cellViewModels: categories.map(makeCategoryImageTableViewCellViewModel))
    }
    
    // MARK: - Cell View Model Methods
    private func makeCategoryImageTableViewCellViewModel(category: Category) -> CategoryImageTableViewCellViewModel {
        return CategoryImageTableViewCellViewModel(
            identifier: HomeViewController.CellIdentifier.imageTableViewCell.rawValue,
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
