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
import PassKit
import SquareInAppPaymentsSDK

class CheckoutViewModel {
    private let calendar = Calendar.current
    
    private let apiURLRequestFactory = APIURLRequestFactory()
    
    private let pickupDateTableViewCellViewModelDetailTextDateFormatter: DateFormatter = {
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
    
    var paymentMethodTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]() {
        didSet { updateTableViewSectionModels() }
    }
    
    var pickupDateTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]() {
        didSet { updateTableViewSectionModels() }
    }
    
    var errorHandler: (Error) -> Void = { _ in }
    
    // MARK: - Dynamic Properties
    private(set) lazy var tableViewSectionModels = Dynamic(makeTableViewSectionModels())
    
    let paymentMethod: Dynamic<PaymentMethodsViewModel.PaymentMethod?> = Dynamic(nil)
    
    let pickupDate: Dynamic<Date?> = Dynamic(nil)
    
    let minimumPickupDate: Dynamic<Date?> = Dynamic(nil)
    let maximumPickupDate: Dynamic<Date?> = Dynamic(nil)
    
    enum CellIdentifier: String {
        case subtitleTableViewCell
    }
    
    private struct Constants {
        static let paymentMethodTableViewCellViewModelHeight = Double(60)
        static let paymentMethodTableViewCellViewModelDefaultDetailText = "Choose a payment method..."
        
        static let pickupDateTableViewCellViewModelHeight = Double(60)
        static let pickupDateTableViewCellViewModelDefaultDetailText = "ASAP"
        static let pickupDateTableViewCellViewModelDetailTextDateFormat = "h:mm a"
        
        static let paymentSummaryItemLabel = "Sammy's"
    }
    
    init(httpClient: HTTPClient = URLSession.shared,
         userAuthManager: UserAuthManager = Auth.auth()) {
        self.httpClient = httpClient
        self.userAuthManager = userAuthManager
        setUp()
    }
    
    // MARK: - Setup Methods
    private func setUp() {
        paymentMethod.bind { _ in self.updateTableViewSectionModels() }
        if SQIPInAppPaymentsSDK.canUseApplePay {
            paymentMethod.value = .applePay
        }
    }
    
    private func setUp(for outstandingOrder: OutstandingOrder) {
        pickupDate.value = outstandingOrder.preparedForDate
        updateTableViewSectionModels()
    }
    
    private func setUp(for storeDateHours: StoreDateHours) {
        let currentDate = Date()
        if let openingDate = storeDateHours.openingDate,
            let minimumPickupDate = max(currentDate, openingDate).roundedToNextQuarterHour(calendar: calendar) {
            self.minimumPickupDate.value = minimumPickupDate
        }
        maximumPickupDate.value = storeDateHours.closingDate
    }
    
    private func updateTableViewSectionModels() {
        tableViewSectionModels.value = makeTableViewSectionModels()
    }
    
    // MARK: - Download Methods
    func beginDownloads() {
        when(fulfilled: [
            beginOutstandingOrderDownload(),
            _beginStoreHoursDownload()
        ]).catch { self.errorHandler($0) }
    }
    
    func beginStoreHoursDownload() {
        getStoreHours().done(setUp)
            .catch { self.errorHandler($0) }
    }
    
    func beginUpdateOutstandingOrderDownload(preparedForDate: Date?) {
        let currentDate = Date()
        if let date = preparedForDate {
            guard date > currentDate
                else { errorHandler(CheckoutViewModelError.invalidPickupDate); return }
        }
        userAuthManager.getCurrentUserIDToken()
            .then { self.getOutstandingOrder(token: $0) }.get { outstandingOrder in
                outstandingOrder.preparedForDate = preparedForDate
        }.then(beginUpdateOutstandingOrder).catch { self.errorHandler($0) }
    }
    
    func beginPaymentRequestDownload(successHandler: @escaping (PKPaymentRequest) -> Void = { _ in }) {
        userAuthManager.getCurrentUserIDToken()
            .then(getOutstandingOrder)
            .map(makePaymentRequest)
            .done(successHandler)
            .catch(errorHandler)
    }
    
    func beginCreatePurchasedOrderDownload(customerCardID: String, successHandler: @escaping (PurchasedOrder.ID) -> Void = { _ in }) {
        beginCreatePurchasedOrderDownload(cardNonce: nil, customerCardID: customerCardID)
            .done { successHandler($0.id) }
            .catch(errorHandler)
    }
    
    func beginCreatePurchasedOrderDownload(payment: PKPayment, completionHandler: @escaping (Result<PurchasedOrder.ID>) -> Void = { _ in }) {
        beginApplePayNonceDownload(payment: payment)
            .then { self.beginCreatePurchasedOrderDownload(cardNonce: $0.nonce, customerCardID: nil) }
            .done { completionHandler(.fulfilled($0.id)) }
            .catch { completionHandler(.rejected($0)) }
    }
    
    private func _beginStoreHoursDownload() -> Promise<Void> {
        return getStoreHours().done(setUp)
    }
    
    private func beginOutstandingOrderDownload() -> Promise<Void> {
        return userAuthManager.getCurrentUserIDToken()
            .then { self.getOutstandingOrder(token: $0) }.done(setUp)
    }
    
    private func beginUpdateOutstandingOrder(data: OutstandingOrder) -> Promise<Void> {
        return userAuthManager.getCurrentUserIDToken()
            .then { self.updateOutstandingOrder(data: data, token: $0) }.done(setUp)
    }
    
    private func beginApplePayNonceDownload(payment: PKPayment) -> Promise<SQIPCardDetails> {
        return Promise { resolver in
            SQIPApplePayNonceRequest(payment: payment).perform { details, error in
                if let details = details { resolver.fulfill(details) }
                else if let error = error { resolver.reject(error) }
            }
        }
    }
    
    private func beginCreatePurchasedOrderDownload(cardNonce: String?, customerCardID: String?) -> Promise<PurchasedOrder> {
        return userAuthManager.getCurrentUserIDToken()
            .then { self.createPurchasedOrder(data: .init(outstandingOrderID: self.outstandingOrderID ?? preconditionFailure(), cardNonce: cardNonce, customerCardID: customerCardID), token: $0) }
    }
    
    private func getOutstandingOrder(token: JWT) -> Promise<OutstandingOrder> {
        return httpClient.send(apiURLRequestFactory.makeGetOutstandingOrderRequest(id: outstandingOrderID ?? preconditionFailure(), token: token)).validate()
            .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode(OutstandingOrder.self, from: $0.data) }
    }
    
    private func updateOutstandingOrder(data: OutstandingOrder, token: JWT) -> Promise<OutstandingOrder> {
        do {
            return try httpClient.send(apiURLRequestFactory.makeUpdateOutstandingOrderRequest(id: outstandingOrderID ?? preconditionFailure(), data: data, token: token)).validate()
                .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode(OutstandingOrder.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
    }
    
    private func getStoreHours() -> Promise<StoreDateHours> {
        return httpClient.send(apiURLRequestFactory.makeStoreHoursRequest()).validate()
            .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode(StoreDateHours.self, from: $0.data) }
    }
    
    private func createPurchasedOrder(data: CreateUserPurchasedOrderRequestData, token: JWT) -> Promise<PurchasedOrder> {
        do {
            return try httpClient.send(apiURLRequestFactory.makeCreateUserPurchasedOrdersRequest(id: userID ?? preconditionFailure(), data: data, token: token)).validate()
                .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode(PurchasedOrder.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
    }
    
    // MARK: - Factory Methods
    func makeOutstandingOrderTotalPrice(outstandingOrder: OutstandingOrder) -> Int {
        guard let subtotalPrice = outstandingOrder.totalPrice,
            let taxPrice = outstandingOrder.taxPrice else { return 0 }
        return subtotalPrice + taxPrice
    }
    
    func makePaymentRequest(outstandingOrder: OutstandingOrder) -> PKPaymentRequest {
        let request = PKPaymentRequest.squarePaymentRequest(
            merchantIdentifier: AppConstants.ApplePay.merchantID,
            countryCode: AppConstants.ApplePay.countryCode,
            currencyCode: AppConstants.ApplePay.currencyCode
        )
        request.paymentSummaryItems = [PKPaymentSummaryItem(label: Constants.paymentSummaryItemLabel, amount: NSDecimalNumber(value: makeOutstandingOrderTotalPrice(outstandingOrder: outstandingOrder).toUSDUnits()))]
        return request
    }
    
    // MARK: - Section Model Methods
    private func makeTableViewSectionModels() -> [UITableViewSectionModel] {
        let outstandingOrderSection = UITableViewSectionModel(cellViewModels: [
            makePaymentMethodTableViewCellViewModel(),
            makePickupDateTableViewCellViewModel()
        ])
        return [outstandingOrderSection]
    }
    
    // MARK: - Cell View Model Methods
    private func makePaymentMethodTableViewCellViewModel() -> PaymentMethodTableViewCellViewModel {
        return PaymentMethodTableViewCellViewModel(
            identifier: CellIdentifier.subtitleTableViewCell.rawValue,
            height: .fixed(Constants.paymentMethodTableViewCellViewModelHeight),
            actions: paymentMethodTableViewCellViewModelActions,
            configurationData: .init(detailText: paymentMethod.value?.name ?? Constants.paymentMethodTableViewCellViewModelDefaultDetailText))
    }
    
    private func makePickupDateTableViewCellViewModel() -> PickupDateTableViewCellViewModel {
        let detailText: String
        if let date = pickupDate.value { detailText = pickupDateTableViewCellViewModelDetailTextDateFormatter.string(from: date) }
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
    struct PaymentMethodTableViewCellViewModel: UITableViewCellViewModel {
        let identifier: String
        let height: UITableViewCellViewModelHeight
        let actions: [UITableViewCellAction: UITableViewCellActionHandler]
        let configurationData: ConfigurationData
        
        struct ConfigurationData {
            let detailText: String?
        }
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

enum CheckoutViewModelError: Error {
    case invalidPickupDate
}
