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
    private typealias GetItemsDownload = Download<URLRequest, Promise<[Item]>, [Item]>
    
    var httpClient: HTTPClient
    private let apiURLRequestFactory = APIURLRequestFactory()
    
    // MARK: - Section Model Properties
    private var _tableViewSectionModels: [UITableViewSectionModel] {
        var sectionModels = [UITableViewSectionModel]()
        if let itemsSectionModel = itemsTableViewSectionModel { sectionModels.append(itemsSectionModel) }
        return sectionModels
    }
    private var itemsTableViewSectionModel: UITableViewSectionModel?
    
    // MARK: - View Settable Properties
    /// The category ID of the items to present. Required to be non-`nil`.
    var categoryID: Category.ID?
    /// The selected items` category item IDs.
    var selectedCategoryItemIDs = [UUID]()
    
    var itemTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]()
    var errorHandler: ((Error) -> Void)?
    
    // MARK: - Dynamic Properties
    let tableViewSectionModels = Dynamic([UITableViewSectionModel]())
    let isItemsDownloading = Dynamic(false)
    
    private struct Constants {
        static let itemTableViewCellViewModelHeight: Double = 60
    }
    
    init(httpClient: HTTPClient = URLSessionHTTPClient()) {
        self.httpClient = httpClient
    }
    
    // MARK: - Download Methods
    func beginDownloads() {
        bindAndRunStateUpdate(to: makeGetItemsDownload())
    }
    
    private func makeGetItemsDownload() -> GetItemsDownload {
        return GetItemsDownload(source: apiURLRequestFactory.makeGetCategoryItemsRequest(id: categoryID ?? preconditionFailure()))
    }
    
    private func bindAndRunStateUpdate(to download: GetItemsDownload) {
        download.state.bindAndRun { state in
            switch state {
            case .willDownload(let request):
                download.state.value = .downloading(self.httpClient.send(request)
                    .map { try JSONDecoder().decode([Item].self, from: $0.data) })
            case .downloading(let itemsPromise):
                self.isItemsDownloading.value = true
                itemsPromise.get { download.state.value = .completed(.success($0)) }
                    .catch { download.state.value = .completed(.failure($0)) }
            case .completed(let result):
                self.isItemsDownloading.value = false
                switch result {
                case .success(let items):
                    self.itemsTableViewSectionModel = UITableViewSectionModel(
                        cellViewModels: items.map(self.makeItemTableViewCellViewModel)
                    )
                    self.tableViewSectionModels.value = self._tableViewSectionModels
                case .failure(let error): self.errorHandler?(error)
                }
            }
        }
    }
    
    // MARK: - Cell View Model Methods
    private func makeItemTableViewCellViewModel(item: Item) -> ItemTableViewCellViewModel {
        return ItemTableViewCellViewModel(
            identifier: ItemsViewController.CellIdentifier.cell.rawValue,
            height: Constants.itemTableViewCellViewModelHeight,
            actions: itemTableViewCellViewModelActions,
            configurationData: .init(text: item.name, categoryItemID: item.categoryItemID),
            selectionData: .init(categoryItemID: item.categoryItemID)
        )
    }
}

extension ItemsViewModel {
    struct ItemTableViewCellViewModel: UITableViewCellViewModel {
        let identifier: String
        let height: Double
        let actions: [UITableViewCellAction: UITableViewCellActionHandler]
        
        let configurationData: ConfigurationData
        let selectionData: SelectionData
        
        struct ConfigurationData {
            let text: String
            let categoryItemID: UUID?
        }
        
        struct SelectionData {
            let categoryItemID: UUID?
        }
    }
}
