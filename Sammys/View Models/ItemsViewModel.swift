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
        didSet { updateTableViewSectionModels() }
    }
    
    // MARK: - View Settable Properties
    /// The category ID of the items to present.
    /// Required to be non-`nil` before beginning downloads.
    var categoryID: Category.ID?
    
    /// The selected items` category item IDs.
    var selectedCategoryItemIDs = [Item.CategoryItemID]()
    
    var itemTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]()
    
    var errorHandler: ((Error) -> Void)?
    
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
    private func updateTableViewSectionModels() {
        tableViewSectionModels.value = makeTableViewSectionModels()
    }
    
    // MARK: - Download Methods
    func beginDownloads() {
        beginItemsDownload()
    }
    
    private func beginItemsDownload() {
        getItems().done { items in
            self.itemsTableViewSectionModel = self.makeItemsTableViewSectionModel(items: items) }
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
        let isSelected: () -> Bool = {
            guard let id = item.categoryItemID else { return false }
            return self.selectedCategoryItemIDs.contains(id)
        }
        
        return ItemTableViewCellViewModel(
            identifier: CellIdentifier.subtitleTableViewCell.rawValue,
            height: .fixed(Constants.itemTableViewCellViewModelHeight),
            actions: itemTableViewCellViewModelActions,
            configurationData: .init(text: item.name, detailText: item.price?.toUSDUnits().toPriceString(), isSelected: isSelected()),
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
            let isSelected: () -> Bool
        }
    }
}
