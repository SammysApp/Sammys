//
//  ItemsViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/25/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

class ItemsViewModel {
    private let apiURLRequestFactory = APIURLRequestFactory()
    
    // MARK: - Dependencies
    var httpClient: HTTPClient
    
    // MARK: - Section Model Properties
    private var itemsTableViewSectionModel: UITableViewSectionModel? {
        didSet { tableViewSectionModels.value = makeTableViewSectionModels() }
    }
    
    // MARK: - View Settable Properties
    /// The category ID of the items to present. Required to be non-`nil`.
    var categoryID: Category.ID?
    /// The selected items` category item IDs.
    var selectedCategoryItemIDs = [Item.CategoryItemID]()
    
    var itemTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]()
    var errorHandler: ((Error) -> Void)?
    
    // MARK: - Dynamic Properties
    let tableViewSectionModels = Dynamic([UITableViewSectionModel]())
    let isItemsDownloading = Dynamic(false)
    
    private struct Constants {
        static let itemTableViewCellViewModelHeight: Double = 60
    }
    
    init(httpClient: HTTPClient = URLSession.shared) {
        self.httpClient = httpClient
    }
    
    // MARK: - Download Methods
    func beginDownloads() {
        beginItemsDownload()
    }
    
    private func beginItemsDownload() {
        isItemsDownloading.value = true
        getItems()
            .done { self.itemsTableViewSectionModel = self.makeItemsTableViewSectionModel(items: $0) }
            .ensure { self.isItemsDownloading.value = false }
            .catch { self.errorHandler?($0) }
    }
    
    private func getItems() -> Promise<[Item]> {
        return httpClient.send(apiURLRequestFactory.makeGetCategoryItemsRequest(id: categoryID ?? preconditionFailure())).validate()
            .map { try JSONDecoder().decode([Item].self, from: $0.data) }
    }
    
    // MARK: - Section Model Methods
    private func makeTableViewSectionModels() -> [UITableViewSectionModel] {
        var sectionModels = [UITableViewSectionModel]()
        if let itemsModel = itemsTableViewSectionModel { sectionModels.append(itemsModel) }
        return sectionModels
    }
    
    private func makeItemsTableViewSectionModel(items: [Item]) -> UITableViewSectionModel {
        return UITableViewSectionModel(cellViewModels: items.map(makeItemTableViewCellViewModel))
    }
    
    // MARK: - Cell View Model Methods
    private func makeItemTableViewCellViewModel(item: Item) -> ItemTableViewCellViewModel {
        return ItemTableViewCellViewModel(
            identifier: ItemsViewController.CellIdentifier.tableViewCell.rawValue,
            height: .fixed(Constants.itemTableViewCellViewModelHeight),
            actions: itemTableViewCellViewModelActions,
            configurationData: .init(text: item.name, categoryItemID: item.categoryItemID),
            selectionData: .init(categoryItemID: item.categoryItemID)
        )
    }
}

extension ItemsViewModel {
    struct ItemTableViewCellViewModel: UITableViewCellViewModel {
        let identifier: String
        let height: UITableViewCellViewModelHeight
        let actions: [UITableViewCellAction: UITableViewCellActionHandler]
        
        let configurationData: ConfigurationData
        let selectionData: SelectionData
        
        struct ConfigurationData {
            let text: String
            let categoryItemID: Item.CategoryItemID?
        }
        
        struct SelectionData {
            let categoryItemID: Item.CategoryItemID?
        }
    }
}
