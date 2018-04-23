//
//  BagViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/28/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import Stripe

enum BagItemKey {
    case food, quantity
}

protocol BagItem {
    var key: BagItemKey { get }
}

struct BagItemGroup {
    let items: [BagItem]
}

struct BagSection {
    let title: String?
    let itemGroups: [BagItemGroup]
    
    var allItems: [BagItem] {
        return itemGroups.flatMap { $0.items }
    }
    
    init(title: String? = nil, itemGroups: [BagItemGroup]) {
        self.title = title
        self.itemGroups = itemGroups
    }
}

protocol BagViewModelDelegate {
    func didEdit(_ food: Food)
    func paymentDidComplete(with paymentResult: PaymentResult)
}

enum PaymentResult {
    case success
    case failure(String)
}

class BagViewModel: NSObject {
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
                var itemGroups = [BagItemGroup]()
                for food in foods {
                    var items = [BagItem]()
                    items.append(FoodBagItem(food: food))
                    if let quantityItem = quantityItem(for: food) {
                        items.append(quantityItem)
                    }
                    itemGroups.append(BagItemGroup(items: items))
                }
                sections.append(BagSection(itemGroups: itemGroups))
            }
        }
        return sections
    }
    
    private var quantityItems = [QuantityBagItem]()
    
    var subtotalPrice: Double {
        var totalPrice = 0.0
        foods.forEach { $1.forEach { totalPrice += $0.price } }
        return totalPrice.rounded(toPlaces: 2)
    }
    
    var taxPrice: Double {
        return (subtotalPrice * (6.88/100)).rounded(toPlaces: 2)
    }
    
    var finalPrice: Double {
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
        return sections[section].allItems.count
    }
    
    func item(for indexPath: IndexPath) -> BagItem? {
        return sections[indexPath.section].allItems[indexPath.row]
    }
    
    func cellViewModels(in section: Int) -> [TableViewCellViewModel] {
        let section = sections[section]
        var cellViewModels = [TableViewCellViewModel]()
        section.allItems.forEach {
            // FIXME: Missing quantity item
            switch $0 {
            case let foodBagItem as FoodBagItem:
                cellViewModels.append(FoodBagTableViewCellViewModelFactory(food: foodBagItem.food, didEdit: { cell in
                    self.delegate?.didEdit(foodBagItem.food) })
                    .create())
            default: break
            }
        }
        return cellViewModels
    }
    
    func remove(at indexPath: IndexPath, didRemoveSection: ((Bool) -> Void)?) {
        guard let food = (item(for: indexPath) as? FoodBagItem)?.food else { return }
        data.remove(food, didRemoveSection: didRemoveSection)
    }
    
    func quantityItem(for food: Food) -> QuantityBagItem? {
        return quantityItems.first { $0.food.isEqual(food) }
    }
    
    func showQuantity(for food: Food) {
        quantityItems.append(QuantityBagItem(food: food))
    }
    
    func hideQuantity(for food: Food) {
        quantityItems = quantityItems.filter { !$0.food.isEqual(food) }
    }
    
    func finishEditing() {
        data.save()
    }
    
    func clearBag() {
        data.clear()
    }
    
    func chargeSource(with id: String, completed: ((Error?) -> Void)? = nil) {
        PayAPIClient.chargeSource(id, amount: finalPrice.toCents()) { result in
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

class FoodBagItem: BagItem {
    let key: BagItemKey = .food
    let food: Food
    
    init(food: Food) {
        self.food = food
    }
}

class QuantityBagItem: BagItem {
    let key: BagItemKey = .quantity
    let food: Food
    
    init(food: Food) {
        self.food = food
    }
}
