//
//  BagViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/28/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import Stripe

struct CellViewModelFoodGroup {
    let food: Food
    let cellViewModels: [TableViewCellViewModel]
}

struct BagSection {
    let title: String?
    let cellViewModelFoodGroups: [CellViewModelFoodGroup]
    
    var allCellViewModels: [TableViewCellViewModel] {
        return cellViewModelFoodGroups.flatMap { $0.cellViewModels }
    }
    
    init(title: String? = nil, cellViewModelFoodGroups: [CellViewModelFoodGroup]) {
        self.title = title
        self.cellViewModelFoodGroups = cellViewModelFoodGroups
    }
}

protocol BagViewModelDelegate {
    func bagDataDidChange()
    func didEdit(food: Food)
    func didSelect(food: Food)
    func delete(indexPaths: [IndexPath])
    func delete(sections: IndexSet)
    func paymentDidComplete(with paymentResult: PaymentResult)
}

enum PaymentResult {
    case success
    case failure(String)
}

class BagViewModel: NSObject {
    private struct Constants {
        
    }
    
    var user: User? {
        return UserDataStore.shared.user
    }
    
    var delegate: BagViewModelDelegate?
    
    let paymentContext = STPPaymentContext(customerContext: STPCustomerContext(keyProvider: EphemeralKeyProvider.shared))
    
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
                var cellViewModelFoodGroups = [CellViewModelFoodGroup]()
                for food in foods {
                    let cellViewModels = [
                        FoodBagTableViewCellViewModelFactory(
                            food: food,
                            height: UITableViewAutomaticDimension,
                            didSelect: { self.delegate?.didSelect(food: $0) },
                            didEdit: { cell in self.delegate?.didEdit(food: food) })
                            .create(),
                        FoodQuantityTableViewCellViewModelFactory(
                            food: food,
                            height: 80,
                            didSelectQuantity: { self.changeQuantity($1, for: $0) }).create()
                    ]
                    cellViewModelFoodGroups.append(CellViewModelFoodGroup(food: food, cellViewModels: cellViewModels))
                }
                sections.append(BagSection(cellViewModelFoodGroups: cellViewModelFoodGroups))
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
    
    var numberOfSections: Int {
        return sections.count
    }
    
    override init() {
        super.init()
        paymentContext.delegate = self
        paymentContext.configuration.createCardSources = true
    }
    
    func numberOfRows(in section: Int) -> Int {
        return sections[section].allCellViewModels.count
    }
    
    func cellViewModels(in section: Int) -> [TableViewCellViewModel] {
        return sections[section].allCellViewModels
    }
    
    func cellViewModel(for indexPath: IndexPath) -> TableViewCellViewModel {
        return cellViewModels(in: indexPath.section)[indexPath.row]
    }
    
    func indexPath(for food: Food) -> IndexPath? {
        var indexPath: IndexPath?
        sections.enumerated().forEach { sectionIndex, section in
            section.cellViewModelFoodGroups.enumerated().forEach { rowIndex, group in
                if group.food.isEqual(food) {
                    indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                }
            }
        }
        return indexPath
    }
    
    func remove(_ food: Food) {
        guard let indexPath = self.indexPath(for: food) else { return }
        data.remove(food) { didRemoveSection in
            if didRemoveSection { self.delegate?.delete(sections: [indexPath.section]) }
            else { self.delegate?.delete(indexPaths: [indexPath]) }
        }
    }
    
    func removeFood(at indexPath: IndexPath) {
        remove(sections[indexPath.section].cellViewModelFoodGroups[indexPath.row].food)
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
    
    func chargeSource(with id: String, completed: ((Error?) -> Void)? = nil) {
        PayAPIClient.chargeSource(id, amount: totalPrice.toCents()) { result in
            switch result {
            case .success: completed?(nil)
            case .failure(let error): completed?(error)
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
    
    func addToUserOrders() {
        guard let user = user else { return }
        let order = Order(number: "123", date: Date(), foods: foods)
        UserAPIClient.add(order, for: user)
    }
}

// MARK: - STPPaymentContextDelegate
extension BagViewModel: STPPaymentContextDelegate {
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        
    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
//        guard let label = paymentContext.selectedPaymentMethod?.label else { return }
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        chargeCard(with: paymentResult.source.stripeID, completed: completion)
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        if let errorMessage = error?.localizedDescription {
            delegate?.paymentDidComplete(with: .failure(errorMessage))
        } else {
            delegate?.paymentDidComplete(with: .success)
        }
    }
}
