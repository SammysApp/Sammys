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
    typealias ItemsDownload = DownloadState<URLRequest, Promise<[Item]>, [Item]>
    
    var httpClient: HTTPClient = URLSessionHTTPClient()
    private let apiURLRequestFactory = APIURLRequestFactory()
    
    private(set) var itemsDownload: ItemsDownload? {
        didSet {
            guard let download = itemsDownload else { return }
            handleItemsDownload(download)
        }
    }
    private var itemsTableViewSectionModel: UITableViewSectionModel?
    private var _tableViewSectionModels: [UITableViewSectionModel] {
        var sectionModels = [UITableViewSectionModel]()
        if let itemsSectionModel = itemsTableViewSectionModel { sectionModels.append(itemsSectionModel) }
        return sectionModels
    }
    
    // MARK: - View Settable Properties
    var categoryID: Category.ID?
    var selectedCategoryItemIDs = [UUID]()
    var itemTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]()
    var errorHandler: ((Error) -> Void)?
    
    // MARK: - Dynamic Properties
    let tableViewSectionModels = Dynamic([UITableViewSectionModel]())
    let isItemsDownloading = Dynamic(false)
    
    private struct Constants {
        static let itemTableViewCellViewModelHeight: Double = 60
    }
    
    func beginDownloads() {
        itemsDownload = makeItemsDownload()
    }
    
    private func handleItemsDownload(_ download: ItemsDownload) {
        switch download {
        case .willDownload(let request):
            itemsDownload = .downloading(httpClient.send(request)
                .map { try JSONDecoder().decode([Item].self, from: $0.data) })
        case .downloading(let promise):
            isItemsDownloading.value = true
            promise.get { self.itemsDownload = .completed(.success($0)) }
                .catch { self.itemsDownload = .completed(.failure($0)) }
        case .completed(let result):
            isItemsDownloading.value = false
            switch result {
            case .success(let items):
                itemsTableViewSectionModel = UITableViewSectionModel(cellViewModels: items.map(makeItemTableViewCellViewModel))
                tableViewSectionModels.value = _tableViewSectionModels
            case .failure(let error): errorHandler?(error)
            }
        }
    }
    
    private func makeItemsDownload() -> ItemsDownload {
        return .willDownload(apiURLRequestFactory.makeGetCategoryItemsRequest(id: categoryID ?? preconditionFailure()))
    }
    
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
