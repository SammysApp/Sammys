//
//  HomeViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/21/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit
import FirebaseAuth

class HomeViewModel {
    private let apiURLRequestFactory = APIURLRequestFactory()
    
    // MARK: - Dependencies
    var httpClient: HTTPClient
    var userAuthManager: UserAuthManager
    
    // MARK: - View Settable Properties
    var userID: User.ID?
    
    var purchasedOrderTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]()
    
    var categoryImageTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]()
    
    var errorHandler: (Error) -> Void = { _ in }
    
    // MARK: - View Gettable Properties
    var isUserSignedIn: Bool {
        return userAuthManager.isUserSignedIn
    }
    
    // MARK: - Dynamic Properties
    private(set) lazy var tableViewSectionModels = Dynamic(makeTableViewSectionModels())
    
    let isDataRefreshable = Dynamic(false)
    
    let isLoading = Dynamic(false)
    
    // MARK: - Section Model Properties
    private var purchasedOrdersTableViewSectionModel: UITableViewSectionModel? {
        didSet { updateTableViewSectionModels() }
    }
    
    private var categoriesTableViewSectionModel: UITableViewSectionModel? {
        didSet { updateTableViewSectionModels() }
    }
    
    enum CellIdentifier: String {
        case tableViewCell
        case imageTableViewCell
    }
    
    enum Color {
        case purchasedOrderTableViewCellViewModelProgressIsPendingBackgroundColor
        case purchasedOrderTableViewCellViewModelProgressIsPreparingBackgroundColor
        case purchasedOrderTableViewCellViewModelProgressIsCompletedBackgroundColor
    }
    
    private struct Constants {
        static let purchasedOrderTableViewCellViewModelProgressIsPendingProgressText = "Pending Preparation"
        static let purchasedOrderTableViewCellViewModelProgressIsPreparingProgressText = "Being Prepared"
        static let purchasedOrderTableViewCellViewModelProgressIsCompletedProgressText = "Ready For Pickup"
        
        static let purchasedOrderTableViewCellViewModelHeight = Double(60)
        
        static let categoryImageTableViewCellViewModelHeight = Double(200)
    }
    
    init(httpClient: HTTPClient = URLSession.shared,
         userAuthManager: UserAuthManager = Auth.auth()) {
        self.httpClient = httpClient
        self.userAuthManager = userAuthManager
    }
    
    // MARK: - Setup Methods
    private func setUp(for categories: [Category]) {
        categoriesTableViewSectionModel = makeCategoriesTableViewSectionModel(categories: categories)
    }
    
    private func setUp(for purchasedOrders: [PurchasedOrder]) {
        isDataRefreshable.value = !purchasedOrders.isEmpty
        purchasedOrdersTableViewSectionModel = makePurchasedOrdersTableViewSectionModel(purchasedOrders: purchasedOrders)
    }
    
    private func updateTableViewSectionModels() {
        tableViewSectionModels.value = makeTableViewSectionModels()
    }
    
    // MARK: - Download Methods
    func beginDownloads() {
        isLoading.value = true
        makeDownloads()
            .ensure { self.isLoading.value = false }
            .catch(errorHandler)
    }
    
    func beginUserIDDownload(successHandler: @escaping () -> Void = {}) {
        isLoading.value = true
        userAuthManager.getCurrentUserIDToken()
            .then { self.getTokenUser(token: $0) }
            .ensure { self.isLoading.value = false }
            .get { self.userID = $0.id }.asVoid()
            .done(successHandler)
            .catch(errorHandler)
    }
    
    private func beginCategoriesDownload() -> Promise<Void> {
        return getRootCategories().done(setUp)
    }
    
    private func beginPurchasedOrdersDownload() -> Promise<Void> {
        return userAuthManager.getCurrentUserIDToken()
            .then { self.getPurchasedOrders(token: $0) }
            .done(setUp)
    }
    
    private func makeDownloads() -> Promise<Void> {
        var downloads = [beginCategoriesDownload()]
        if userID != nil {
            downloads.append(beginPurchasedOrdersDownload())
        }
        return when(fulfilled: downloads)
    }
    
    private func getRootCategories() -> Promise<[Category]> {
        return httpClient.send(apiURLRequestFactory.makeGetCategoriesRequest(queryData: .init(isRoot: true))).validate()
            .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode([Category].self, from: $0.data) }
    }
    
    private func getPurchasedOrders(token: JWT) -> Promise<[PurchasedOrder]> {
        return httpClient.send(apiURLRequestFactory.makeGetUserPurchasedOrdersRequest(id: userID ?? preconditionFailure(), token: token)).validate()
            .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode([PurchasedOrder].self, from: $0.data) }
    }
    
    private func getTokenUser(token: JWT) -> Promise<User> {
        return httpClient.send(apiURLRequestFactory.makeGetTokenUserRequest(token: token)).validate()
            .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode(User.self, from: $0.data) }
    }
    
    // MARK: - Factory Methods
    private func makePurchasedOrderTableViewCellViewModelProgressText(purchasedOrder: PurchasedOrder) -> String {
        switch purchasedOrder.progress {
        case .isPending:
            return Constants.purchasedOrderTableViewCellViewModelProgressIsPendingProgressText
        case .isPreparing:
            return Constants.purchasedOrderTableViewCellViewModelProgressIsPreparingProgressText
        case .isCompleted:
            return Constants.purchasedOrderTableViewCellViewModelProgressIsCompletedProgressText
        }
    }
    
    private func makePurchasedOrderTableViewCellViewModelBackgroundColor(purchasedOrder: PurchasedOrder) -> Color {
        switch purchasedOrder.progress {
        case .isPending:
            return Color.purchasedOrderTableViewCellViewModelProgressIsPendingBackgroundColor
        case .isPreparing:
            return Color.purchasedOrderTableViewCellViewModelProgressIsPreparingBackgroundColor
        case .isCompleted:
            return Color.purchasedOrderTableViewCellViewModelProgressIsCompletedBackgroundColor
        }
    }
    
    // MARK: - Section Model Methods
    private func makePurchasedOrdersTableViewSectionModel(purchasedOrders: [PurchasedOrder]) -> UITableViewSectionModel? {
        guard !purchasedOrders.isEmpty else { return nil }
        return UITableViewSectionModel(cellViewModels: purchasedOrders.map(makePurchasedOrderTableViewCellViewModel))
    }
    
    private func makeCategoriesTableViewSectionModel(categories: [Category]) -> UITableViewSectionModel? {
        guard !categories.isEmpty else { return nil }
        return UITableViewSectionModel(cellViewModels: categories.map(makeCategoryImageTableViewCellViewModel))
    }
    
    private func makeTableViewSectionModels() -> [UITableViewSectionModel] {
        var sectionModels = [UITableViewSectionModel]()
        if let purchasedOrdersModel = purchasedOrdersTableViewSectionModel {
            sectionModels.append(purchasedOrdersModel)
        }
        if let categoriesModel = categoriesTableViewSectionModel {
            sectionModels.append(categoriesModel)
        }
        return sectionModels
    }
    
    // MARK: - Cell View Model Methods
    private func makePurchasedOrderTableViewCellViewModel(purchasedOrder: PurchasedOrder) -> PurchasedOrderTableViewCellViewModel {
        return PurchasedOrderTableViewCellViewModel(
            identifier: CellIdentifier.tableViewCell.rawValue,
            height: .fixed(Constants.purchasedOrderTableViewCellViewModelHeight),
            actions: purchasedOrderTableViewCellViewModelActions,
            configurationData: .init(text: "Order #\(purchasedOrder.number)", progressText: makePurchasedOrderTableViewCellViewModelProgressText(purchasedOrder: purchasedOrder), backgroundColor: makePurchasedOrderTableViewCellViewModelBackgroundColor(purchasedOrder: purchasedOrder))
        )
    }
    
    private func makeCategoryImageTableViewCellViewModel(category: Category) -> CategoryImageTableViewCellViewModel {
        let model = CategoryImageTableViewCellViewModel(
            identifier: CellIdentifier.imageTableViewCell.rawValue,
            height: .fixed(Constants.categoryImageTableViewCellViewModelHeight),
            actions: categoryImageTableViewCellViewModelActions,
            configurationData: .init(text: category.name),
            selectionData: .init(id: category.id, title: category.name)
        )
        
        if let imageURLString = category.imageURL,
            let imageURL = URL(string: imageURLString) {
            httpClient.send(URLRequest(url: imageURL))
                .done { model.configurationData.imageData.value = $0.data }
                .catch { self.errorHandler($0) }
        }
        
        return model
    }
}

extension HomeViewModel {
    struct PurchasedOrderTableViewCellViewModel: UITableViewCellViewModel {
        let identifier: String
        let height: UITableViewCellViewModelHeight
        let actions: [UITableViewCellAction: UITableViewCellActionHandler]
        
        let configurationData: ConfigurationData
        
        struct ConfigurationData {
            let text: String
            let progressText: String
            let backgroundColor: Color
        }
    }
}

extension HomeViewModel {
    struct CategoryImageTableViewCellViewModel: UITableViewCellViewModel {
        let identifier: String
        let height: UITableViewCellViewModelHeight
        let actions: [UITableViewCellAction: UITableViewCellActionHandler]
        
        let configurationData: ConfigurationData
        let selectionData: SelectionData
        
        struct ConfigurationData {
            let text: String
            let imageData = Dynamic<Data?>(nil)
        }
        
        struct SelectionData {
            let id: Category.ID
            let title: String
        }
    }
}
