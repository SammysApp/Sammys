//
//  CheckoutViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/31/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit
import FirebaseAuth

class CheckoutViewModel {
    private let apiURLRequestFactory = APIURLRequestFactory()
    
    private var storeHoursDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    private var pickupDateTableViewCellViewModelDetailTextDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.pickupDateTableViewCellViewModelDetailTextDateFormat
        return formatter
    }()
    
    // MARK: - Dependencies
    var httpClient: HTTPClient
    var userAuthManager: UserAuthManager
    
    // MARK: - View Settable Properties
    /// Required to be non-`nil` before beginning downloads.
    var outstandingOrderID: OutstandingOrder.ID?
    
    /// Required to be non-`nil` before beginning downloads.
    var userID: User.ID?
    
    var pickupDate: Date? {
        didSet { updateTableViewSectionModels() }
    }
    
    var pickupDateTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]() {
        didSet { updateTableViewSectionModels() }
    }
    
    var errorHandler: ((Error) -> Void)?
    
    // MARK: - Dynamic Properties
    private(set) lazy var tableViewSectionModels = Dynamic(makeTableViewSectionModels())
    
    let minimumPickupDate: Dynamic<Date?> = Dynamic(nil)
    let maximumPickupDate: Dynamic<Date?> = Dynamic(nil)
    
    enum CellIdentifier: String {
        case subtitleTableViewCell
    }
    
    private struct Constants {
        static let pickupDateTableViewCellViewModelHeight = Double(60)
        static let pickupDateTableViewCellViewModelDefaultDetailText = "ASAP"
        static let pickupDateTableViewCellViewModelDetailTextDateFormat = "h:mm a"
    }
    
    init(httpClient: HTTPClient = URLSession.shared,
         userAuthManager: UserAuthManager = Auth.auth()) {
        self.httpClient = httpClient
        self.userAuthManager = userAuthManager
    }
    
    // MARK: - Setup Methods
    private func updateTableViewSectionModels() {
        tableViewSectionModels.value = makeTableViewSectionModels()
    }
    
    // MARK: - Download Methods
    func beginDownloads() {
        firstly { self.beginStoreHoursDownload() }
            .catch { self.errorHandler?($0) }
    }
    
    func beginCreatePurchasedOrderDownload(cardNonce: String, completionHandler: @escaping (Result<PurchasedOrder.ID>) -> Void) {
        userAuthManager.getCurrentUserIDToken()
            .then { self.createPurchasedOrder(data: .init(outstandingOrderID: self.outstandingOrderID ?? preconditionFailure(), cardNonce: cardNonce, customerCardID: nil), token: $0) }
            .done { completionHandler(.fulfilled($0.id)) }
            .catch { completionHandler(.rejected($0)) }
    }
    
    private func beginStoreHoursDownload() -> Promise<Void> {
        return getStoreHours().done { storeHours in
            self.minimumPickupDate.value = storeHours.openingDate
            self.maximumPickupDate.value = storeHours.closingDate
        }
    }
    
    private func getStoreHours() -> Promise<StoreHours> {
        return httpClient.send(apiURLRequestFactory.makeStoreHoursRequest()).validate()
            .map { try self.storeHoursDecoder.decode(StoreHours.self, from: $0.data) }
    }
    
    private func createPurchasedOrder(data: CreateUserPurchasedOrderRequestData, token: JWT) -> Promise<PurchasedOrder> {
        do {
            return try httpClient.send(apiURLRequestFactory.makeCreateUserPurchasedOrdersRequest(id: userID ?? preconditionFailure(), data: data, token: token)).validate()
                .map { try JSONDecoder().decode(PurchasedOrder.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
    }
    
    // MARK: - Section Model Methods
    private func makeTableViewSectionModels() -> [UITableViewSectionModel] {
        let outstandingOrderSection = UITableViewSectionModel(cellViewModels: [makePickupDateTableViewCellViewModel()])
        return [outstandingOrderSection]
    }
    
    private func makePickupDateTableViewCellViewModel() -> PickupDateTableViewCellViewModel {
        let detailText: String
        if let date = pickupDate { detailText = pickupDateTableViewCellViewModelDetailTextDateFormatter.string(from: date) }
        else { detailText = Constants.pickupDateTableViewCellViewModelDefaultDetailText }
        
        return PickupDateTableViewCellViewModel(
            identifier: CellIdentifier.subtitleTableViewCell.rawValue,
            height: .fixed(Constants.pickupDateTableViewCellViewModelHeight),
            actions: pickupDateTableViewCellViewModelActions,
            configurationData: .init(detailText: detailText)
        )
    }
}

extension CheckoutViewModel {
    struct PickupDateTableViewCellViewModel: UITableViewCellViewModel {
        let identifier: String
        let height: UITableViewCellViewModelHeight
        let actions: [UITableViewCellAction: UITableViewCellActionHandler]
        let configurationData: ConfigurationData
        
        struct ConfigurationData {
            let detailText: String
        }
    }
}
