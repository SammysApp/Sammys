//
//  PaymentMethodsViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/13/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit
import FirebaseAuth
import SquareInAppPaymentsSDK

class PaymentMethodsViewModel {
    private var cards = [Card]()
    
    private let apiURLRequestFactory = APIURLRequestFactory()
    
    // MARK: - Dependencies
    var httpClient: HTTPClient
    var userAuthManager: UserAuthManager
    
    // MARK: - View Settable Properties
    /// Required to be non-`nil` before beginning downloads.
    var userID: User.ID?
    
    var paymentMethodTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]() {
        didSet { updatePaymentMethodsTableViewSectionModel() }
    }
    
    var selectedPaymentMethod: PaymentMethod? {
        didSet {
            if let method = selectedPaymentMethod { didSelectPaymentMethodHandler(method) }
            updatePaymentMethodsTableViewSectionModel()
        }
    }
    
    var didSelectPaymentMethodHandler: (PaymentMethod) -> Void = { _ in }
    
    var errorHandler: (Error) -> Void = { _ in }
    
    // MARK: - Dynamic Properties
    private(set) lazy var tableViewSectionModels = Dynamic(makeTableViewSectionModels())
    
    // MARK: - Section Model Properties
    private var paymentMethodsTableViewSectionModel: UITableViewSectionModel? {
        didSet { updateTableViewSectionModels() }
    }
    
    enum PaymentMethod: Equatable {
        case applePay
        case card(Card.ID, name: String)
        
        var name: String {
            switch self {
            case .applePay: return Constants.applePayPaymentMethodName
            case .card(_, let name): return name
            }
        }
    }
    
    enum CellIdentifier: String {
        case tableViewCell
    }
    
    private struct Constants {
        static let applePayPaymentMethodName = "Apple Pay"
        
        static let paymentMethodTableViewCellViewModelHeight = Double(60)
    }
    
    init(httpClient: HTTPClient = URLSession.shared,
         userAuthManager: UserAuthManager = Auth.auth()) {
        self.httpClient = httpClient
        self.userAuthManager = userAuthManager
    }
    
    // MARK: - Setup Methods
    private func setUp(for cards: [Card]) {
        self.cards = cards
        updatePaymentMethodsTableViewSectionModel()
    }
    
    private func updatePaymentMethodsTableViewSectionModel() {
        paymentMethodsTableViewSectionModel = makePaymentMethodsTableViewSectionModel(cards: cards)
    }
    
    private func updateTableViewSectionModels() {
        tableViewSectionModels.value = makeTableViewSectionModels()
    }
    
    // MARK: - Download Methods
    func beginDownloads() {
        beginCardsDownload()
            .catch(errorHandler)
    }
    
    func beginCreateCardDownload(cardNonce: String, postalCode: String, completionHandler: @escaping (Result<Void>) -> Void = { _ in }) {
        userAuthManager.getCurrentUserIDToken()
            .then { self.createCard(cardNonce: cardNonce, postalCode: postalCode, token: $0).asVoid() }
            .done { completionHandler(.fulfilled(())) }
            .then(beginCardsDownload)
            .catch { completionHandler(.rejected($0)) }
    }
    
    private func beginCardsDownload() -> Promise<Void> {
        return userAuthManager.getCurrentUserIDToken()
            .then(getCards).done(setUp)
    }
    
    private func getCards(token: JWT) -> Promise<[Card]> {
        return httpClient.send(apiURLRequestFactory.makeGetUserCardsRequest(id: userID ?? preconditionFailure(), token: token)).validate()
            .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode([Card].self, from: $0.data) }
    }
    
    private func createCard(cardNonce: String, postalCode: String, token: JWT) -> Promise<Card> {
        do {
            // FIXME: Use real card nonce in production.
            return try httpClient.send(apiURLRequestFactory.makeCreateUserCardRequest(id: userID ?? preconditionFailure(), data: .init(cardNonce: "fake-card-nonce-ok", postalCode: postalCode), token: token)).validate()
                .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode(Card.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
    }
    
    // MARK: - Factory Methods
    private func makePaymentMethods(cards: [Card] = []) -> [PaymentMethod] {
        return (SQIPInAppPaymentsSDK.canUseApplePay ? [.applePay] : []) + cards.map { .card($0.id, name: $0.name) }
    }
    
    // MARK: - Section Model Methods
    private func makePaymentMethodsTableViewSectionModel(cards: [Card] = []) -> UITableViewSectionModel {
        return UITableViewSectionModel(cellViewModels: makePaymentMethods(cards: cards).map(makePaymentMethodTableViewCellViewModel))
    }
    
    private func makeTableViewSectionModels() -> [UITableViewSectionModel] {
        var sectionModels = [UITableViewSectionModel]()
        if let paymentMethodsModel = paymentMethodsTableViewSectionModel {
            sectionModels.append(paymentMethodsModel)
        }
        return sectionModels
    }
    
    // MARK: - Cell View Model Methods
    private func makePaymentMethodTableViewCellViewModel(method: PaymentMethod) -> PaymentMethodTableViewCellViewModel {
        return PaymentMethodTableViewCellViewModel(
            identifier: CellIdentifier.tableViewCell.rawValue,
            height: .fixed(Constants.paymentMethodTableViewCellViewModelHeight),
            actions: paymentMethodTableViewCellViewModelActions,
            configurationData: .init(text: method.name, isSelected: method == selectedPaymentMethod),
            selectionData: .init(method: method)
        )
    }
}

extension PaymentMethodsViewModel {
    struct PaymentMethodTableViewCellViewModel: UITableViewCellViewModel {
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
            let method: PaymentMethod
        }
    }
}
