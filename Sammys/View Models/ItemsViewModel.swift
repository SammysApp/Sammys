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
    
    private var items = [Item]()
    
    // MARK: - Dependencies
    var httpClient: HTTPClient
    
    // MARK: - View Settable Properties
    /// The category ID of the items to present.
    /// Required to be non-`nil` before beginning downloads.
    var categoryID: Category.ID?
    
    /// The selected items` category item IDs.
    var selectedCategoryItemIDs = [Item.CategoryItemID]() {
        didSet { updateItemsTableViewSectionModel() }
    }
    
    var itemTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]()
    
    var minimumItems: Int?
    var maximumItems: Int?
    
    var addItemHandler: ((Item.CategoryItemID) -> Void) = { _ in }
    var removeItemHandler: ((Item.CategoryItemID) -> Void) = { _ in }
    
    var addModifierHandler: ((Modifier.ID) -> Void) = { _ in }
    var removeModifierHandler: ((Modifier.ID) -> Void) = { _ in }
    
    var errorHandler: (Error) -> Void = { _ in }
    
    // MARK: - Dynamic Properties
    private(set) lazy var tableViewSectionModels = Dynamic(makeTableViewSectionModels())
    
    // MARK: - Section Model Properties
    private var itemsTableViewSectionModel: UITableViewSectionModel? {
        didSet { updateTableViewSectionModels() }
    }
    
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
        itemsTableViewSectionModel = makeItemsTableViewSectionModel(items: items)
    }
    
    private func updateTableViewSectionModels() {
        tableViewSectionModels.value = makeTableViewSectionModels()
    }
    
    // MARK: - Methods
    func add(_ categoryItemID: Item.CategoryItemID) {
        if let maximumItems = maximumItems {
            if let minimumItems = minimumItems,
                minimumItems == maximumItems && selectedCategoryItemIDs.count == maximumItems {
                removeItemHandler(selectedCategoryItemIDs.removeLast())
            } else {
                guard selectedCategoryItemIDs.count < maximumItems
                    else { errorHandler(ItemsViewModelError.reachedMaximumItems); return }
            }
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
    func beginDownloads(successHandler: @escaping () -> Void = {}) {
        firstly { self.beginCategoryDownload() }
            .then { self.beginItemsDownload() }
            .done(successHandler)
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
    private func makeItemsTableViewSectionModel(items: [Item]) -> UITableViewSectionModel {
        return UITableViewSectionModel(cellViewModels: items.map(makeItemTableViewCellViewModel))
    }
    
    private func makeTableViewSectionModels() -> [UITableViewSectionModel] {
        var sectionModels = [UITableViewSectionModel]()
        if let itemsModel = itemsTableViewSectionModel { sectionModels.append(itemsModel) }
        return sectionModels
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
            selectionData: .init(itemID: item.id, categoryItemID: item.categoryItemID, isSelected: isSelected, isModifiersRequired: item.minimumModifiers != nil)
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
            let itemID: Item.ID
            let categoryItemID: Item.CategoryItemID?
            let isSelected: Bool
            let isModifiersRequired: Bool
        }
    }
}

enum ItemsViewModelError: Error {
    case reachedMaximumItems
    case reachedMinimumItems
}
