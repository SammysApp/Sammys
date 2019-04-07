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
        didSet { updateTableViewSectionModels() }
    }
    
    // MARK: - View Settable Properties
    var categoryImageTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]()
    
    var errorHandler: ((Error) -> Void)?
    
    // MARK: - Dynamic Properties
    private(set) lazy var tableViewSectionModels = Dynamic(makeTableViewSectionModels())
    
    enum CellIdentifier: String {
        case imageTableViewCell
    }
    
    private struct Constants {
        static let categoryImageTableViewCellViewModelHeight = Double(200)
    }
    
    init(httpClient: HTTPClient = URLSession.shared) {
        self.httpClient = httpClient
    }
    
    // MARK: - Setup Methods
    private func updateTableViewSectionModels() {
        tableViewSectionModels.value = makeTableViewSectionModels()
    }
    
    // MARK: - Download Methods
    func beginDownloads() {
        beginCategoriesDownload()
    }
    
    private func beginCategoriesDownload() {
        getRootCategories().done { categories in
            self.categoriesTableViewSectionModel = self.makeCategoriesTableViewSectionModel(categories: categories)
        }.catch { self.errorHandler?($0) }
    }
    
    private func getRootCategories() -> Promise<[Category]> {
        return httpClient.send(apiURLRequestFactory.makeGetCategoriesRequest(queryData: .init(isRoot: true))).validate()
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
        let model = CategoryImageTableViewCellViewModel(
            identifier: CellIdentifier.imageTableViewCell.rawValue,
            height: .fixed(Constants.categoryImageTableViewCellViewModelHeight),
            actions: categoryImageTableViewCellViewModelActions,
            configurationData: .init(text: category.name),
            selectionData: .init(id: category.id, title: category.name)
        )
        
        if let imageURLString = category.imageURL,
            let imageURL = URL(string: imageURLString) {
            httpClient.send(URLRequest(url: imageURL))
                .done { model.configurationData.imageData.value = $0.data }
                .catch { self.errorHandler?($0) }
        }
        
        return model
    }
}

extension HomeViewModel {
    struct CategoryImageTableViewCellViewModel: UITableViewCellViewModel {
        let identifier: String
        let height: UITableViewCellViewModelHeight
        let actions: [UITableViewCellAction: UITableViewCellActionHandler]
        
        let configurationData: ConfigurationData
        let selectionData: SelectionData
        
        struct ConfigurationData {
            let text: String
            let imageData = Dynamic<Data?>(nil)
        }
        
        struct SelectionData {
            let id: Category.ID
            let title: String
        }
    }
}
