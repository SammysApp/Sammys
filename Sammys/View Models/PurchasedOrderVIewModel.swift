//
//  PurchasedOrderViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/2/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

class PurchasedOrderViewModel {
    private let apiURLRequestFactory = APIURLRequestFactory()
    
    // MARK: - Dependencies
    var httpClient: HTTPClient
    
    // MARK: - View Settable Properties
    /// Required to be non-`nil` before beginning downloads.
    var purchasedOrderID: PurchasedOrder.ID?
    
    var progressTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]()
    
    var errorHandler: (Error) -> Void = { _ in }
    
    // MARK: - Dynamic Properties
    let title: Dynamic<String?> = Dynamic(nil)
    
    private(set) lazy var tableViewSectionModels = Dynamic(makeTableViewSectionModels())
    
    // MARK: - Section Model Properties
    private var progressTableViewSectionModel: UITableViewSectionModel? {
        didSet { updateTableViewSectionModels() }
    }
    
    enum CellIdentifier: String {
        case progressTableViewCell
    }
    
    enum Color {
        case progressIsPendingColor
        case progressIsPreparingColor
        case progressIsCompletedColor
    }
    
    enum Image {
        case progressIsPendingImage
        case progressIsPreparingImage
        case progressIsCompletedImage
    }
    
    private struct Constants {
        static let progressIsPendingText = "Pending Preparation"
        static let progressIsPreparingText = "Being Prepared"
        static let porgressIsCompletedText = "Ready For Pickup"
        
        static let progressTableViewCellViewModelHeight = Double(100)
    }
    
    init(httpClient: HTTPClient = URLSession.shared) {
        self.httpClient = httpClient
    }
    
    // MARK: - Setup Methods
    private func setUp(for purchasedOrder: PurchasedOrder) {
        title.value = makeTitle(purchasedOrder: purchasedOrder)
        progressTableViewSectionModel = makeProgressTableViewSectionModel(purchasedOrder: purchasedOrder)
    }
    
    private func updateTableViewSectionModels() {
        tableViewSectionModels.value = makeTableViewSectionModels()
    }
    
    // MARK: - Download Methods
    func beginDownloads() {
        firstly { self.beginPurchasedOrderDownload() }
            .catch(errorHandler)
    }
    
    private func beginPurchasedOrderDownload() -> Promise<Void> {
        return getPurchasedOrder().done(setUp)
    }
    
    private func getPurchasedOrder() -> Promise<PurchasedOrder> {
        return httpClient.send(apiURLRequestFactory.makeGetPurchasedOrderRequest(id: purchasedOrderID ?? preconditionFailure())).validate()
            .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode(PurchasedOrder.self, from: $0.data) }
    }
    
    // MARK: - Factory Methods
    private func makeTitle(purchasedOrder: PurchasedOrder) -> String? {
        return "Order #\(purchasedOrder.number)"
    }
    
    private func makeProgressText(orderProgess: OrderProgress) -> String {
        switch orderProgess {
        case .isPending: return Constants.progressIsPendingText
        case .isPreparing: return Constants.progressIsPreparingText
        case .isCompleted: return Constants.porgressIsCompletedText
        }
    }
    
    private func makeProgressColor(orderProgess: OrderProgress) -> Color {
        switch orderProgess {
        case .isPending: return Color.progressIsPendingColor
        case .isPreparing: return Color.progressIsPreparingColor
        case .isCompleted: return Color.progressIsCompletedColor
        }
    }
    
    private func makeProgressImage(orderProgess: OrderProgress) -> Image {
        switch orderProgess {
        case .isPending: return Image.progressIsPendingImage
        case .isPreparing: return Image.progressIsPreparingImage
        case .isCompleted: return Image.progressIsCompletedImage
        }
    }
    
    // MARK: - Section Model Methods
    private func makeProgressTableViewSectionModel(purchasedOrder: PurchasedOrder) -> UITableViewSectionModel {
        return UITableViewSectionModel(cellViewModels: [makeProgressTableViewCellViewModel(purchasedOrder: purchasedOrder)])
    }
    
    private func makeTableViewSectionModels() -> [UITableViewSectionModel] {
        var sectionModels = [UITableViewSectionModel]()
        if let progressModel = progressTableViewSectionModel {
            sectionModels.append(progressModel)
        }
        return sectionModels
    }
    
    // MARK: - Cell View Model Properties
    private func makeProgressTableViewCellViewModel(purchasedOrder: PurchasedOrder) -> ProgressTableViewCellViewModel {
        return ProgressTableViewCellViewModel(
            identifier: CellIdentifier.progressTableViewCell.rawValue,
            height: .fixed(Constants.progressTableViewCellViewModelHeight),
            actions: progressTableViewCellViewModelActions,
            configurationData: .init(progressText: makeProgressText(orderProgess: purchasedOrder.progress), color: makeProgressColor(orderProgess: purchasedOrder.progress), image: makeProgressImage(orderProgess: purchasedOrder.progress))
        )
    }
}

extension PurchasedOrderViewModel {
    struct ProgressTableViewCellViewModel: UITableViewCellViewModel {
        let identifier: String
        let height: UITableViewCellViewModelHeight
        let actions: [UITableViewCellAction: UITableViewCellActionHandler]
        let configurationData: ConfigurationData
        
        struct ConfigurationData {
            let progressText: String
            let color: Color
            let image: Image
        }
    }
}
