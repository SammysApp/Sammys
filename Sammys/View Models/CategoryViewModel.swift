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
    
    // MARK: - View Settable Properties
    /// The parent category ID of the categories to present.
    /// If left `nil`, will present all available categories.
    var parentCategoryID: Category.ID?
    
    var categoryTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]()
    
    var errorHandler: (Error) -> Void  = { _ in }
    
    // MARK: - Dynamic Properties
    private(set) lazy var tableViewSectionModels = Dynamic(makeTableViewSectionModels())
    
    let isLoading = Dynamic(false)
    
    // MARK: - Section Model Properties
    private var categoriesTableViewSectionModel: UITableViewSectionModel? {
        didSet { updateTableViewSectionModels() }
    }
    
    enum CellIdentifier: String {
        case tableViewCell
    }
    
    private struct Constants {
        static let categoryTableViewCellViewModelHeight = Double(100)
    }
    
    init(httpClient: HTTPClient = URLSession.shared) {
        self.httpClient = httpClient
    }
    
    // MARK: - Setup Methods
    private func setUp(for categories: [Category]) {
        categoriesTableViewSectionModel = makeCategoriesTableViewSectionModel(categories: categories)
    }
    
    private func updateTableViewSectionModels() {
        tableViewSectionModels.value = makeTableViewSectionModels()
    }
    
    // MARK: - Download Methods
    func beginDownloads() {
        isLoading.value = true
        beginCategoriesDownload()
            .ensure { self.isLoading.value = false }
            .catch(errorHandler)
    }
    
    private func beginCategoriesDownload() -> Promise<Void> {
        return getCategories().done(setUp)
    }
    
    private func getCategories() -> Promise<[Category]> {
        return httpClient.send(makeGetCategoriesRequest()).validate()
            .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode([Category].self, from: $0.data) }
    }
    
    private func makeGetCategoriesRequest() -> URLRequest {
        if let id = parentCategoryID {
            return apiURLRequestFactory.makeGetSubcategoriesRequest(parentCategoryID: id)
        } else { return apiURLRequestFactory.makeGetCategoriesRequest() }
    }
    
    // MARK: - Section Model Methods
    private func makeCategoriesTableViewSectionModel(categories: [Category]) -> UITableViewSectionModel {
        return UITableViewSectionModel(cellViewModels: categories.map(makeCategoryTableViewCellViewModel))
    }
    
    private func makeTableViewSectionModels() -> [UITableViewSectionModel] {
        var sectionModels = [UITableViewSectionModel]()
        if let categoriesModel = categoriesTableViewSectionModel { sectionModels.append(categoriesModel) }
        return sectionModels
    }
    
    // MARK: - Cell View Model Methods
    private func makeCategoryTableViewCellViewModel(category: Category) -> CategoryTableViewCellViewModel {
        return CategoryTableViewCellViewModel(
            identifier: CellIdentifier.tableViewCell.rawValue,
            height: .fixed(Constants.categoryTableViewCellViewModelHeight),
            actions: categoryTableViewCellViewModelActions,
            configurationData: .init(text: category.name),
            selectionData: .init(id: category.id, title: category.name, isConstructable: category.isConstructable, isParentCategory: category.isParentCategory)
        )
    }
}

extension CategoryViewModel {
    struct CategoryTableViewCellViewModel: UITableViewCellViewModel {
        let identifier: String
        let height: UITableViewCellViewModelHeight
        let actions: [UITableViewCellAction: UITableViewCellActionHandler]
        
        let configurationData: ConfigurationData
        let selectionData: SelectionData
        
        struct ConfigurationData {
            let text: String
        }
        
        struct SelectionData {
            let id: Category.ID
            let title: String?
            let isConstructable: Bool
            let isParentCategory: Bool?
        }
    }
}
