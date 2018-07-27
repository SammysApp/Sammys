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

protocol BagViewModelDelegate: class {
    func needsUIUpdate()
    func didStartLoadingPickupData()
    func didFinishLoadingPickupData()
    func bagDataDidChange()
    func didEdit(food: Food)
    func didFave(food: Food)
    func didSelect(food: Food)
    func noteTextViewDidChange(_ textView: UITextView)
    func delete(indexPaths: [IndexPath])
    func delete(sections: IndexSet)
    func paymentMethodDidChange(_ paymentMethod: STPPaymentMethod)
    func purchaseDidComplete(with purchaseResult: PurchaseResult)
}

enum PurchaseResult {
    case success
    case failure(String)
}

class BagViewModel: NSObject {
    private struct Constants { }
    
    var user: User? {
        return UserDataStore.shared.user
    }
    
    weak var delegate: BagViewModelDelegate?
    
    var pickupDate: PickupDate? {
        didSet {
            delegate?.needsUIUpdate()
        }
    }
    
    private var sammys: SammysDataStore {
        return SammysDataStore.shared
    }
    
    private var hours = [Hours]()
    
    var isPickupDateViewControllerShowing = false
    
    var paymentContextHostViewController: UIViewController? {
        didSet {
            if paymentContextHostViewController != nil {
                paymentContext?.hostViewController = paymentContextHostViewController
            }
        }
    }
    
    private var paymentContext: STPPaymentContext?
    
    private let data = BagDataStore.shared
    
    private var foods: BagDataStore.Foods {
        return data.foods
    }
    
    private var sortedFoodTypes: [FoodType] {
        return Array(foods.keys).sorted { $0.rawValue < $1.rawValue }
    }
    
    private var pickupDateAvailabilityCheckerConfiguration: PickupDateAvailabilityCheckerConfiguration {
        return PickupDateAvailabilityCheckerConfiguration(startDate: Date(), hours: hours, amountOfFutureDays: 7, timePickerInterval: 10)
    }
    
    private var pickupDateAvailabilityChecker: PickupDateAvailabilityChecker {
        return PickupDateAvailabilityChecker(pickupDateAvailabilityCheckerConfiguration)
    }
    
    private var sections: [BagSection] {
        var sections = [BagSection]()
        for foodType in sortedFoodTypes {
            if let foods = foods[foodType] {
                var cellViewModels = [TableViewCellViewModel]()
                for food in foods {
                    cellViewModels.append(
                        FoodBagTableViewCellViewModelFactory(
                            user: user,
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
        let configurationCommandParameters = NoteConfigurationParameters(textViewDidChange: delegate?.noteTextViewDidChange)
        let configurationCommand = BagNoteTableViewCellConfigurationCommand(parameters: configurationCommandParameters)
        sections.append(BagSection(title: "Special Instructions", cellViewModels: [
            NoteTableViewCellViewModelFactory<DefaultNoteTableViewCellIdentifier>(identifier: .noteCell, height: UITableViewAutomaticDimension, configurationCommand: configurationCommand).create()
        ]))
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
        return user == nil || environment == .family
    }
    
    var shouldHideTotalVisualEffectView: Bool {
        return foods.isEmpty
    }
    
    var shouldEnableDoneButton: Bool {
        return !isPickupDateViewControllerShowing
    }
    
    var shouldEnableClearButton: Bool {
        return !foods.isEmpty && !isPickupDateViewControllerShowing
    }
    
    var paymentStackViewSpacing: CGFloat {
        return shouldHideCreditCardButton ? 20 : 10
    }
    
    var pickupDateButtonText: String {
        if let pickupDate = pickupDate {
            switch pickupDate {
            case .asap: return "Pickup ASAP"
            case .future(let date):
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd, h:mm a"
                return formatter.string(from: date)
            }
        } else {
            return "Choose Pickup"
        }
    }
    
    var purchaseButtonText: String {
        return doesGetForFree ? "Order Free 😍" : totalPrice.priceString
    }
    
    var userName: String?
    
    var orderNote: String?
    
    var orderUserName: String? {
        return user?.name ?? userName
    }
    
    var doesGetForFree: Bool {
        return environment == .family
    }
    
    var isPickupASAPAvailable: Bool {
        return pickupDateAvailabilityChecker.isPickupASAPAvailable(for: Date())
    }
    
    var isPickupDateSet: Bool {
        return pickupDate != nil
    }
    
    var numberOfSections: Int {
        return sections.count
    }
    
    override init() {
        super.init()
        
        if !doesGetForFree {
            setupPaymentContext()
        }
        
        setupHours()
    }
    
    func setupHours() {
        guard let hours = sammys.hours else {
            delegate?.didStartLoadingPickupData()
            sammys.setHours(didComplete: handleDidSetupHours)
            return
        }
        handleDidSetupHours(hours)
    }
    
    func handleDidSetupHours(_ hours: [Hours]) {
        self.hours = hours
        pickupDate = isPickupASAPAvailable ? .asap : nil
        delegate?.didFinishLoadingPickupData()
    }
    
    func setupPaymentContext() {
        paymentContext = STPPaymentContext(customerContext: STPCustomerContext(keyProvider: EphemeralKeyProvider.shared))
        paymentContext?.delegate = self
        paymentContext?.largeTitleDisplayMode = .never
        paymentContext?.configuration.createCardSources = true
        if paymentContextHostViewController != nil {
            paymentContext?.hostViewController = paymentContextHostViewController
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
    
    func title(forSection section: Int) -> String? {
        return sections[section].title
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
    
    func fave(_ food: Food, completed: (() -> Void)? = nil) {
        guard let user = user else { return }
        let originalQuantity = food.quantity
        food.quantity = 1
        UserAPIClient.set(food, for: user) {
            if $0 == nil { completed?() }
        }
        food.quantity = originalQuantity
    }
    
    func updateFave(_ food: Food) {
        guard let user = user else { return }
        UserAPIClient.checkIfFoodIsAFavorite(food, for: user) { foodIsAFavorite in
            if foodIsAFavorite {
                self.fave(food)
            }
        }
    }
    
    func removeFave(_ food: Food, completed: (() -> Void)? = nil) {
        guard let user = user else { return }
        UserAPIClient.remove(food, for: user) {
            if $0 == nil { completed?() }
        }
    }
    
    func handleDidTapFave(_ food: Food, completed: (() -> Void)? = nil) {
        guard let user = user else { return }
        UserAPIClient.checkIfFoodIsAFavorite(food, for: user) { foodIsAFavorite in
            if foodIsAFavorite { self.removeFave(food) { completed?() } }
            else { self.fave(food) { completed?() } }
        }
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
        paymentContext?.presentPaymentMethodsViewController()
    }
    
    func updatePaymentPrice() {
        paymentContext?.paymentAmount = totalPrice.toCents()
    }
    
    func requestPayment() {
        paymentContext?.requestPayment()
    }
    
    func handleDidTapPurchase() {
        if doesGetForFree {
            delegate?.purchaseDidComplete(with: .success)
        } else { requestPayment() }
    }
    
    func chargeSource(with id: String, completed: ((Error?) -> Void)? = nil) {
        PaymentAPIManager.chargeSource(id: id, amount: totalPrice.toCents())
        .get {
            self.delegate?.purchaseDidComplete(with: .success)
            completed?(nil)
        }
        .catch { error in
            self.delegate?.purchaseDidComplete(with: .failure(error.localizedDescription))
            completed?(error)
        }
    }
    
    func chargeCard(with id: String, completed: ((Error?) -> Void)? = nil) {
        guard let user = user,
            let amount = paymentContext?.paymentAmount else { return }
        UserAPIClient.getCustomerID(for: user) { result in
            switch result {
            case .success(let customerID):
                PaymentAPIManager.chargeCustomerSource(sourceID: id, customerID: customerID, amount: amount)
                .get { completed?(nil) }
                .catch { completed?($0) }
            case .failure: break
            }
        }
    }
    
    func addToOrders(didComplete: ((Order) -> Void)? = nil) {
        guard let userName = orderUserName else { fatalError() }
        let date = Date()
        var pickupDate: Date?
        if case .future(let date) = self.pickupDate! {
            pickupDate = date
        }
        //OrdersAPIClient.fetchNewOrderNumber { number in
            let order = Order(number: "1", userName: userName, userID: self.user?.id, date: date, pickupDate: pickupDate, foods: self.foods, note: self.orderNote)
            //OrdersAPIClient.add(order)
            didComplete?(order)
            self.clearBag()
        //}
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
        case .success: delegate?.purchaseDidComplete(with: .success)
        case .error:
            if let errorMessage = error?.localizedDescription {
                delegate?.purchaseDidComplete(with: .failure(errorMessage))
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
