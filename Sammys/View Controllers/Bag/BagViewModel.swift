//
//  BagViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/28/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import Stripe

private struct BagSection {
    let title: String?
    let cellViewModels: [TableViewCellViewModel]
    
    init(title: String? = nil, cellViewModels: [TableViewCellViewModel]) {
        self.title = title
        self.cellViewModels = cellViewModels
    }
}

protocol BagViewModelDelegate {
    func bagDataDidChange()
    func didEdit(food: Food)
    func didFave(food: Food)
    func didSelect(food: Food)
    func delete(indexPaths: [IndexPath])
    func delete(sections: IndexSet)
    func paymentMethodDidChange(_ paymentMethod: STPPaymentMethod)
    func paymentDidComplete(with paymentResult: PaymentResult)
}

enum PaymentResult {
    case success
    case failure(String)
}

class BagViewModel: NSObject {
    private struct Constants { }
    
    var user: User? {
        return UserDataStore.shared.user
    }
    
    var delegate: BagViewModelDelegate?
    
    var paymentContextHostViewController: UIViewController? {
        didSet {
            if paymentContextHostViewController != nil {
                paymentContext.hostViewController = paymentContextHostViewController
            }
        }
    }
    
    private var paymentContext: STPPaymentContext!
    
    private let data = BagDataStore.shared
    
    private var foods: BagDataStore.Foods {
        return data.foods
    }
    
    private var sortedFoodTypes: [FoodType] {
        return Array(foods.keys).sorted { $0.rawValue < $1.rawValue }
    }
    
    private var sections: [BagSection] {
        var sections = [BagSection]()
        for foodType in sortedFoodTypes {
            if let foods = foods[foodType] {
                var cellViewModels = [TableViewCellViewModel]()
                for food in foods {
                    cellViewModels.append(
                        FoodBagTableViewCellViewModelFactory(
                            food: food,
                            height: UITableViewAutomaticDimension,
                            selectedQuantity: { food.quantity },
                            didSelect: { self.delegate?.didSelect(food: $0) },
                            didEdit: { cell in self.delegate?.didEdit(food: food) },
                            didFave: { cell in self.delegate?.didFave(food: food) },
                            didSelectQuantity: { self.changeQuantity($1, for: $0) })
                            .create()
                    )
                }
                sections.append(BagSection(cellViewModels: cellViewModels))
            }
        }
        return sections
    }
    
    var subtotalPrice: Double {
        var totalPrice = 0.0
        foods.forEach { $1.forEach { totalPrice += $0.price } }
        return totalPrice.rounded(toPlaces: 2)
    }
    
    var taxPrice: Double {
        return (subtotalPrice * (6.88/100)).rounded(toPlaces: 2)
    }
    
    var totalPrice: Double {
        return (subtotalPrice + taxPrice).rounded(toPlaces: 2)
    }
    
    var shouldHideCreditCardButton: Bool {
        return user == nil
    }
    
    var paymentStackViewSpacing: CGFloat {
        return shouldHideCreditCardButton ? 20 : 10
    }
    
    var userName: String?
    
    var orderUserName: String? {
        return user?.name ?? userName
    }
    
    var numberOfSections: Int {
        return sections.count
    }
    
    override init() {
        super.init()
        
        setupPaymentContext()
    }
    
    func setupPaymentContext() {
        paymentContext = STPPaymentContext(customerContext: STPCustomerContext(keyProvider: EphemeralKeyProvider.shared))
        paymentContext.delegate = self
        paymentContext.largeTitleDisplayMode = .never
        paymentContext.configuration.createCardSources = true
        if paymentContextHostViewController != nil {
            paymentContext.hostViewController = paymentContextHostViewController
        }
        updatePaymentPrice()
    }
    
    func numberOfRows(in section: Int) -> Int {
        return sections[section].cellViewModels.count
    }
    
    func cellViewModels(in section: Int) -> [TableViewCellViewModel] {
        return sections[section].cellViewModels
    }
    
    func cellViewModel(for indexPath: IndexPath) -> TableViewCellViewModel {
        return cellViewModels(in: indexPath.section)[indexPath.row]
    }
    
    private func food(at indexPath: IndexPath) -> Food? {
        guard let foodBagTableViewCellViewModel = sections[indexPath.section].cellViewModels[indexPath.row] as? FoodBagTableViewCellViewModel else { return nil }
        return foodBagTableViewCellViewModel.food
    }
    
    private func indexPath(for food: Food) -> IndexPath? {
        var indexPath: IndexPath?
        sections.enumerated().forEach { sectionIndex, section in
            section.cellViewModels.enumerated().forEach { rowIndex, cellViewModel in
                guard let foodBagTableViewCellViewModel = cellViewModel as? FoodBagTableViewCellViewModel else { return }
                if foodBagTableViewCellViewModel.food.isEqual(food) {
                    indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                }
            }
        }
        return indexPath
    }
    
    private func remove(_ food: Food, indexPath: IndexPath) {
        data.remove(food) { didRemoveSection in
            if didRemoveSection { self.delegate?.delete(sections: [indexPath.section]) }
            else { self.delegate?.delete(indexPaths: [indexPath]) }
        }
    }
    
    func remove(_ food: Food) {
        guard let indexPath = indexPath(for: food) else { return }
        remove(food, indexPath: indexPath)
    }
    
    func remove(at indexPath: IndexPath) {
        guard let food = food(at: indexPath) else { return }
        remove(food, indexPath: indexPath)
    }
    
    func fave(_ food: Food) {
        guard let user = user else { return }
        let originalQuantity = food.quantity
        food.quantity = 1
        UserAPIClient.set(food, for: user)
        food.quantity = originalQuantity
    }
    
    func changeQuantity(_ quantity: Quantity, for food: Food) {
        switch quantity {
        case .none:
            remove(food)
        case .some(let amount):
            food.quantity = amount
            saveBag()
            delegate?.bagDataDidChange()
        }
    }
    
    func saveBag() {
        data.save()
    }
    
    func clearBag() {
        data.clear()
    }
    
    func presentPaymentMethodsViewController() {
        paymentContext.presentPaymentMethodsViewController()
    }
    
    func updatePaymentPrice() {
        paymentContext.paymentAmount = totalPrice.toCents()
    }
    
    func requestPayment() {
        paymentContext.requestPayment()
    }
    
    func chargeSource(with id: String, completed: ((Error?) -> Void)? = nil) {
        PayAPIClient.chargeSource(id, amount: totalPrice.toCents()) { result in
            switch result {
            case .success:
                self.delegate?.paymentDidComplete(with: .success)
                completed?(nil)
            case .failure(let error):
                self.delegate?.paymentDidComplete(with: .failure(error.localizedDescription))
                completed?(error)
            }
        }
    }
    
    func chargeCard(with id: String, completed: ((Error?) -> Void)? = nil) {
        guard let user = user else { return }
        UserAPIClient.getCustomerID(for: user) { result in
            switch result {
            case .success(let customerID):
                PayAPIClient.chargeSource(id, customerID: customerID, amount: self.paymentContext.paymentAmount) { result in
                    switch result {
                    case .success: completed?(nil)
                    case .failure(let error): completed?(error)
                    }
                }
            case .failure: break
            }
        }
    }
    
    func addToOrders() {
        guard let userName = orderUserName else { fatalError() }
        let date = Date()
        OrdersAPIClient.fetchNewOrderNumber(for: date) { number in
            let order = Order(number: "\(number)", userName: userName, userID: self.user?.id, date: date, foods: self.foods)
            OrdersAPIClient.add(order, to: date, withNumber: number)
            if let user = self.user { UserAPIClient.add(order, for: user) }
            self.clearBag()
        }
    }
}

// MARK: - STPPaymentContextDelegate
extension BagViewModel: STPPaymentContextDelegate {
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        
    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        guard let paymentMethod = paymentContext.selectedPaymentMethod else { return }
        delegate?.paymentMethodDidChange(paymentMethod)
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        chargeCard(with: paymentResult.source.stripeID, completed: completion)
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        switch status {
        case .success: delegate?.paymentDidComplete(with: .success)
        case .error:
            if let errorMessage = error?.localizedDescription {
                delegate?.paymentDidComplete(with: .failure(errorMessage))
            }
        case .userCancellation: break
        }
    }
}

extension STPAddCardViewController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension STPPaymentMethodsViewController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
