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
    
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        return formatter
    }()
    
    // MARK: - Dependencies
    var httpClient: HTTPClient
    var userAuthManager: UserAuthManager
    
    // MARK: - View Settable Properties
    /// Required to be non-`nil`.
    var outstandingOrderID: OutstandingOrder.ID?
    /// Required to be non-`nil`.
    var userID: User.ID?
    
    var pickupDate: Date? {
        didSet { updateTableViewSectionModels() }
    }
    
    var pickupDateTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]() {
        didSet { updateTableViewSectionModels() }
    }
    
    var errorHandler: ((Error) -> Void)?
    
    // MARK: - Dynamic Properties
    lazy var tableViewSectionModels = Dynamic(makeTableViewSectionModels())
    let minimumPickupDate: Dynamic<Date?> = Dynamic(nil)
    let maximumPickupDate: Dynamic<Date?> = Dynamic(nil)
    
    enum CellIdentifier: String {
        case subtitleTableViewCell
    }
    
    private struct Constants {
        static let dateFormat = "h:mm a"
        static let pickupDateTableViewCellViewModelHeight: Double = 60
        static let pickupDateTableViewCellViewModelDefaultDetailText = "ASAP"
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
    func beginStoreHoursDownload() {
        getStoreHours().done { storeHours in
            self.minimumPickupDate.value = storeHours.openingDate
            self.maximumPickupDate.value = storeHours.closingDate
        }.catch { self.errorHandler?($0) }
    }
    
    func beginCreatePurchasedOrderDownload(cardNonce: String, completionHandler: @escaping (Result<PurchasedOrder.ID>) -> Void) {
        userAuthManager.getCurrentUserIDToken()
            // FIXME: Actually use `cardNonce` in production.
            .then { self.createPurchasedOrder(data: .init(outstandingOrderID: self.outstandingOrderID ?? preconditionFailure(), cardNonce: "fake-card-nonce-ok", customerCardID: nil), token: $0) }
            .done { completionHandler(.fulfilled($0.id)) }
            .catch { completionHandler(.rejected($0)) }
    }
    
    private func getStoreHours() -> Promise<StoreHours> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return httpClient.send(apiURLRequestFactory.makeStoreHoursRequest()).validate()
            .map { try decoder.decode(StoreHours.self, from: $0.data) }
    }
    
    private func createPurchasedOrder(data: CreateUserPurchasedOrderData, token: JWT) -> Promise<PurchasedOrder> {
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
        if let date = pickupDate { detailText = dateFormatter.string(from: date) }
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
