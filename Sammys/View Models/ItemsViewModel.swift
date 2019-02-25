//
//  ItemsViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/25/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

class ItemsViewModel {
    private typealias ItemsDownload = Download<URLRequest, [Item]>
    
    private let httpClient: HTTPClient
    private let apiURLRequestFactory = APIURLRequestFactory()
    
    private var itemsDownload: ItemsDownload? {
        didSet {
            guard let download = itemsDownload else { return }
            handleItemsDownload(download)
        }
    }
    
    // MARK: - View Settable Properties
    var categoryID: Category.ID?
    var itemTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]()
    var errorHandler: ((Error) -> Void)?
    
    // MARK: - Dynamic Properties
    let tableViewSectionModels = Dynamic([UITableViewSectionModel]())
    let isItemsDownloading = Dynamic(false)
    
    init(httpClient: HTTPClient = URLSessionHTTPClient()) {
        self.httpClient = httpClient
    }
    
    func beginDownloads() {
        itemsDownload = makeItemsDownload()
    }
    
    private func handleItemsDownload(_ download: ItemsDownload) {
        switch download {
        case .willDownload(let request):
            itemsDownload = .downloading
            httpClient.send(request)
                .map { try JSONDecoder().decode([Item].self, from: $0.data) }
                .get { self.itemsDownload = .completed(.success($0)) }
                .catch { self.itemsDownload = .completed(.failure($0)) }
        case .downloading:
            isItemsDownloading.value = true
        case .completed(let result):
            isItemsDownloading.value = false
            switch result {
            case .success(let items):
                tableViewSectionModels.value.append(UITableViewSectionModel(cellViewModels: items.map(makeItemTableViewCellViewModel)))
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
            height: 100,
            actions: itemTableViewCellViewModelActions,
            configurationData: .init(text: item.name),
            selectionData: .init()
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
        }
        
        struct SelectionData {}
    }
}
