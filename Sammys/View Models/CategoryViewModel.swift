//
//  CategoryViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/24/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

class CategoryViewModel {
    private let apiURLRequestFactory = APIURLRequestFactory()
    
    // MARK: - Dependencies
    var httpClient: HTTPClient
    
    // MARK: - Section Model Properties
    private var categoriesTableViewSectionModel: UITableViewSectionModel? {
        didSet { tableViewSectionModels.value = makeTableViewSectionModels() }
    }
    
    // MARK: - View Settable Properties
    /// The parent category ID of the categories to present.
    /// If left `nil`, will present all available categories.
    var parentCategoryID: Category.ID?
    
    var categoryTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]()
    var errorHandler: ((Error) -> Void)?
    
    // MARK: - Dynamic Properties
    let tableViewSectionModels = Dynamic([UITableViewSectionModel]())
    let isCategoriesDownloading = Dynamic(false)
    
    private struct Constants {
        static let categoryTableViewCellViewModelHeight: Double = 100
    }
    
    init(httpClient: HTTPClient = URLSessionHTTPClient()) {
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
        return httpClient.send(makeGetCategoriesRequest()).validate()
            .map { try JSONDecoder().decode([Category].self, from: $0.data) }
    }
    
    private func makeGetCategoriesRequest() -> URLRequest {
        if let id = parentCategoryID {
            return apiURLRequestFactory.makeGetSubcategoriesRequest(parentCategoryID: id)
        } else { return apiURLRequestFactory.makeGetCategoriesRequest() }
    }
    
    // MARK: - Section Model Methods
    private func makeTableViewSectionModels() -> [UITableViewSectionModel] {
        var sectionModels = [UITableViewSectionModel]()
        if let categoriesModel = categoriesTableViewSectionModel { sectionModels.append(categoriesModel) }
        return sectionModels
    }
    
    private func makeCategoriesTableViewSectionModel(categories: [Category]) -> UITableViewSectionModel {
        return UITableViewSectionModel(cellViewModels: categories.map(makeCategoryTableViewCellViewModel))
    }
    
    // MARK: - Cell View Model Methods
    private func makeCategoryTableViewCellViewModel(category: Category) -> CategoryTableViewCellViewModel {
        return CategoryTableViewCellViewModel(
            identifier: CategoryViewController.CellIdentifier.cell.rawValue,
            height: Constants.categoryTableViewCellViewModelHeight,
            actions: categoryTableViewCellViewModelActions,
            configurationData: .init(text: category.name),
            selectionData: .init(id: category.id, isConstructable: category.isConstructable, isParentCategory: category.isParentCategory)
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
            let isConstructable: Bool
            let isParentCategory: Bool?
        }
    }
}
