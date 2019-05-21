//
//  ModifiersViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/20/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

class ModifiersViewModel {
    private let apiURLRequestFactory = APIURLRequestFactory()
    
    private var modifiers = [Modifier]()
    
    // MARK: - Dependencies
    var httpClient: HTTPClient
    
    // MARK: - View Settable Properties
    /// The category ID of the item of the modifiers to present.
    /// Required to be non-`nil` before beginning downloads.
    var categoryID: Category.ID?
    /// The item ID of the modifiers to present.
    /// Required to be non-`nil` before beginning downloads.
    var itemID: Item.ID?
    
    var selectedModifierIDs = [Modifier.ID]() {
        didSet { updateModifiersTableViewSectionModel() }
    }
    
    var modifierTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]() {
        didSet { updateModifiersTableViewSectionModel() }
    }
    
    var addModifierHandler: ((Modifier.ID) -> Void) = { _ in }
    var removeModifierHandler: ((Modifier.ID) -> Void) = { _ in }
    
    var errorHandler: (Error) -> Void = { _ in }
    
    // MARK: - Dynamic Properties
    private(set) lazy var tableViewSectionModels = Dynamic(makeTableViewSectionModels())
    
    // MARK: - Section Model Properties
    private var modifiersTableViewSectionModel: UITableViewSectionModel? {
        didSet { updateTableViewSectionModels() }
    }
    
    enum CellIdentifier: String {
        case subtitleTableViewCell
    }
    
    private struct Constants {
        static let modifierTableViewCellViewModelHeight = Double(60)
    }
    
    init(httpClient: HTTPClient = URLSession.shared) {
        self.httpClient = httpClient
    }
    
    // MARK: - Setup Methods
    private func setUp(for modifiers: [Modifier]) {
        self.modifiers = modifiers
        updateModifiersTableViewSectionModel()
    }
    
    private func updateModifiersTableViewSectionModel() {
        modifiersTableViewSectionModel = makeModifiersTableViewSectionModel(modifiers: modifiers)
    }
    
    private func updateTableViewSectionModels() {
        tableViewSectionModels.value = makeTableViewSectionModels()
    }
    
    // MARK: - Methods
    func add(_ modifierID: Modifier.ID) {
        selectedModifierIDs.append(modifierID)
        addModifierHandler(modifierID)
    }
    
    func remove(_ modifierID: Modifier.ID) {
        selectedModifierIDs.remove(modifierID)
        removeModifierHandler(modifierID)
    }
    
    // MARK: - Download Methods
    func beginDownloads() {
        firstly { self.beginModifiersDownload() }
            .catch(errorHandler)
    }
    
    private func beginModifiersDownload() -> Promise<Void> {
        return getModifiers().done(setUp)
    }
    
    private func getModifiers() -> Promise<[Modifier]> {
        return httpClient.send(apiURLRequestFactory.makeGetItemModifiersRequest(categoryID: categoryID ?? preconditionFailure(), itemID: itemID ?? preconditionFailure())).validate()
            .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode([Modifier].self, from: $0.data) }
    }
    
    // MARK: - Section Model Methods
    private func makeModifiersTableViewSectionModel(modifiers: [Modifier]) -> UITableViewSectionModel {
        return UITableViewSectionModel(cellViewModels: modifiers.map(makeModifierTableViewCellViewModel))
    }
    
    private func makeTableViewSectionModels() -> [UITableViewSectionModel] {
        var sectionModels = [UITableViewSectionModel]()
        if let modifiersModel = modifiersTableViewSectionModel {
            sectionModels.append(modifiersModel)
        }
        return sectionModels
    }
    
    // MARK: - Cell View Model Methods
    private func makeModifierTableViewCellViewModel(modifier: Modifier) -> ModifierTableViewCellViewModel {
        let isSelected = selectedModifierIDs.contains(modifier.id)
        return ModifierTableViewCellViewModel(
            identifier: CellIdentifier.subtitleTableViewCell.rawValue,
            height: .fixed(Constants.modifierTableViewCellViewModelHeight),
            actions: modifierTableViewCellViewModelActions,
            configurationData: .init(text: modifier.name, isSelected: isSelected),
            selectionData: .init(modifierID: modifier.id, isSelected: isSelected)
        )
    }
}

extension ModifiersViewModel {
    struct ModifierTableViewCellViewModel: UITableViewCellViewModel {
        let identifier: String
        let height: UITableViewCellViewModelHeight
        let actions: [UITableViewCellAction: UITableViewCellActionHandler]
        
        let configurationData: ConfigurationData
        let selectionData: SelectionData
        
        struct ConfigurationData {
            let text: String
            let isSelected: Bool
        }
        
        struct SelectionData {
            let modifierID: Modifier.ID
            let isSelected: Bool
        }
    }
}
