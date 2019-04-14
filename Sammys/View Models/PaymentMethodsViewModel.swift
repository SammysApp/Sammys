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
    
    var paymentMethodTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]()
    
    var errorHandler: ((Error) -> Void) = { _ in }
    
    // MARK: - Dynamic Properties
    private(set) lazy var tableViewSectionModels = Dynamic(makeTableViewSectionModels())
    
    // MARK: - Section Model Properties
    private var paymentMethodsTableViewSectionModel: UITableViewSectionModel? {
        didSet { updateTableViewSectionModels() }
    }
    
    private enum PaymentMethod {
        case applePay
        case card(Card)
        
        var name: String {
            switch self {
            case .applePay: return Constants.applePayPaymentMethodName
            case .card(let card): return card.name
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
    
    func beginCreateCardDownload(cardNonce: String) {
        userAuthManager.getCurrentUserIDToken()
            .then { self.createCard(cardNonce: cardNonce, token: $0).asVoid() }
            .then(beginCardsDownload)
            .catch(errorHandler)
    }
    
    private func beginCardsDownload() -> Promise<Void> {
        return userAuthManager.getCurrentUserIDToken()
            .then(getCards).done(setUp)
    }
    
    private func getCards(token: JWT) -> Promise<[Card]> {
        return httpClient.send(apiURLRequestFactory.makeGetUserCardsRequest(id: userID ?? preconditionFailure(), token: token)).validate()
            .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode([Card].self, from: $0.data) }
    }
    
    private func createCard(cardNonce: String, token: JWT) -> Promise<Card> {
        do {
            return try httpClient.send(apiURLRequestFactory.makeCreateUserCardRequest(id: userID ?? preconditionFailure(), data: .init(cardNonce: cardNonce), token: token)).validate()
                .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode(Card.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
    }
    
    // MARK: - Factory Methods
    private func makePaymentMethods(cards: [Card] = []) -> [PaymentMethod] {
        return (SQIPInAppPaymentsSDK.canUseApplePay ? [.applePay] : []) + cards.map { .card($0) }
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
            configurationData: .init(text: method.name)
        )
    }
}

extension PaymentMethodsViewModel {
    struct PaymentMethodTableViewCellViewModel: UITableViewCellViewModel {
        let identifier: String
        let height: UITableViewCellViewModelHeight
        let actions: [UITableViewCellAction: UITableViewCellActionHandler]
        let configurationData: ConfigurationData
        
        struct ConfigurationData {
            let text: String
        }
    }
}
