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
    private var items: [Item]?
    
    private let apiURLRequestFactory = APIURLRequestFactory()
    
    // MARK: - Dependencies
    var httpClient: HTTPClient
    
    // MARK: - Section Model Properties
    private var itemsTableViewSectionModel: UITableViewSectionModel? {
        didSet { updateTableViewSectionModels() }
    }
    
    // MARK: - View Settable Properties
    /// The category ID of the items to present.
    /// Required to be non-`nil` before beginning downloads.
    var categoryID: Category.ID?
    
    /// The selected items` category item IDs.
    var itemTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]()
    
    var selectedCategoryItemIDs = [Item.CategoryItemID]() {
        didSet { updateItemsTableViewSectionModel() }
    }
    
    var minimumItems: Int?
    var maximumItems: Int?
    
    var addItemHandler: ((Item.CategoryItemID) -> Void) = { _ in }
    var removeItemHandler: ((Item.CategoryItemID) -> Void) = { _ in }
    
    var errorHandler: ((Error) -> Void) = { _ in }
    
    // MARK: - Dynamic Properties
    private(set) lazy var tableViewSectionModels = Dynamic(makeTableViewSectionModels())
    
    enum CellIdentifier: String {
        case subtitleTableViewCell
    }
    
    private struct Constants {
        static let itemTableViewCellViewModelHeight = Double(60)
    }
    
    init(httpClient: HTTPClient = URLSession.shared) {
        self.httpClient = httpClient
    }
    
    // MARK: - Setup Methods
    private func setUp(for category: Category) {
        minimumItems = category.minimumItems
        maximumItems = category.maximumItems
    }
    
    private func setUp(for items: [Item]) {
        self.items = items
        updateItemsTableViewSectionModel()
    }
    
    private func updateItemsTableViewSectionModel() {
        guard let items = items else { return }
        itemsTableViewSectionModel = makeItemsTableViewSectionModel(items: items)
    }
    
    private func updateTableViewSectionModels() {
        tableViewSectionModels.value = makeTableViewSectionModels()
    }
    
    // MARK: - Methods
    func add(_ categoryItemID: Item.CategoryItemID) {
        if let maximumItems = maximumItems {
            guard selectedCategoryItemIDs.count < maximumItems
                else { errorHandler(ItemsViewModelError.reachedMaximumItems); return }
        }
        selectedCategoryItemIDs.append(categoryItemID)
        addItemHandler(categoryItemID)
    }
    
    func remove(_ categoryItemID: Item.CategoryItemID) {
        if let minimumItems = minimumItems {
            guard selectedCategoryItemIDs.count > minimumItems
                else { errorHandler(ItemsViewModelError.reachedMinimumItems); return }
        }
        selectedCategoryItemIDs.remove(categoryItemID)
        removeItemHandler(categoryItemID)
    }
    
    // MARK: - Download Methods
    func beginDownloads() {
        firstly { self.beginCategoryDownload() }
            .then { self.beginItemsDownload() }
            .catch(errorHandler)
    }
    
    private func beginCategoryDownload() -> Promise<Void> {
        return getCategory().done(setUp)
    }
    
    private func beginItemsDownload() -> Promise<Void> {
        return getItems().done(setUp)
    }
    
    private func getCategory() -> Promise<Category> {
        return httpClient.send(apiURLRequestFactory.makeGetCategoryRequest(id: categoryID ?? preconditionFailure())).validate()
            .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode(Category.self, from: $0.data) }
    }
    
    private func getItems() -> Promise<[Item]> {
        return httpClient.send(apiURLRequestFactory.makeGetCategoryItemsRequest(id: categoryID ?? preconditionFailure())).validate()
            .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode([Item].self, from: $0.data) }
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
        var isSelected = false
        if let id = item.categoryItemID {
            isSelected = selectedCategoryItemIDs.contains(id)
        }
        
        return ItemTableViewCellViewModel(
            identifier: CellIdentifier.subtitleTableViewCell.rawValue,
            height: .fixed(Constants.itemTableViewCellViewModelHeight),
            actions: itemTableViewCellViewModelActions,
            configurationData: .init(text: item.name, detailText: item.price?.toUSDUnits().toPriceString(), isSelected: isSelected),
            selectionData: .init(categoryItemID: item.categoryItemID, isSelected: isSelected)
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
            let detailText: String?
            let isSelected: Bool
        }
        
        struct SelectionData {
            let categoryItemID: Item.CategoryItemID?
            let isSelected: Bool
        }
    }
}

enum ItemsViewModelError: Error {
    case reachedMaximumItems
    case reachedMinimumItems
}
