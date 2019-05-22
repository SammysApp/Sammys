//
//  CategorizedItemsViewModel.swift
//  Kitchen
//
//  Created by Natanel Niazoff on 4/19/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

class CategorizedItemsViewModel {
    // MARK: - Section Model Properties
    private var categorizedItemsTableViewSectionModels: [UITableViewSectionModel]? {
        didSet { updateTableViewSectionModels() }
    }
    
    // MARK: - View Settable Properties
    var categorizedItems = [CategorizedItems]() {
        didSet { updateCategorizedItemsTableViewSectionModels() }
    }
    
    var itemTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]() {
        didSet { updateCategorizedItemsTableViewSectionModels() }
    }
    
    // MARK: - Dynamic Properties
    private(set) lazy var tableViewSectionModels = Dynamic(makeTableViewSectionModels())
    
    enum CellIdentifier: String {
        case subtitleTableViewCell
    }
    
    private struct Constants {
        static let itemTableViewCellViewModelHeight = Double(60)
    }
    
    // MARK: - Setup Methods
    private func updateCategorizedItemsTableViewSectionModels() {
        categorizedItemsTableViewSectionModels = makeCategorizedItemsTableViewSectionModels(categorizedItems: categorizedItems)
    }
    
    private func updateTableViewSectionModels() {
        tableViewSectionModels.value = makeTableViewSectionModels()
    }
    
    // MARK: - Factory Methods
    private func makeItemTableViewCellViewModelDetailText(item: Item) -> String? {
        guard let modifiers = item.modifiers, !modifiers.isEmpty else { return nil }
        return modifiers.map { $0.name }.joined(separator: ", ")
    }
    
    // MARK: - Section Models
    private func makeCategorizedItemsTableViewSectionModels(categorizedItems: [CategorizedItems]) -> [UITableViewSectionModel] {
        return categorizedItems.map { UITableViewSectionModel(title: $0.category.name, cellViewModels: $0.items.map(makeItemTableViewCellViewModels)) }
    }
    
    private func makeTableViewSectionModels() -> [UITableViewSectionModel] {
        var sectionModels = [UITableViewSectionModel]()
        if let categorizedItemsModels = categorizedItemsTableViewSectionModels {
            categorizedItemsModels.forEach { sectionModels.append($0) }
        }
        return sectionModels
    }
    
    // MARK: - Cell View Model Methods
    private func makeItemTableViewCellViewModels(item: Item) -> ItemTableViewCellViewModel {
        return ItemTableViewCellViewModel(
            identifier: CellIdentifier.subtitleTableViewCell.rawValue,
            height: .fixed(Constants.itemTableViewCellViewModelHeight),
            actions: itemTableViewCellViewModelActions,
            configurationData: .init(text: item.name, detailText: makeItemTableViewCellViewModelDetailText(item: item))
        )
    }
}

extension CategorizedItemsViewModel {
    struct CategorizedItems: Codable {
        let category: Category
        let items: [Item]
    }
}

extension CategorizedItemsViewModel {
    struct ItemTableViewCellViewModel: UITableViewCellViewModel {
        let identifier: String
        let height: UITableViewCellViewModelHeight
        let actions: [UITableViewCellAction: UITableViewCellActionHandler]
        let configurationData: ConfigurationData
        
        struct ConfigurationData {
            let text: String
            let detailText: String?
        }
    }
}
