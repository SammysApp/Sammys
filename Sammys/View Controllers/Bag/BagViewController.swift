//
//  BagViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/8/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import Stripe

class BagViewController: UIViewController, Storyboardable {
    typealias ViewController = BagViewController
    
    let viewModel = BagViewModel()
    let paymentContext = STPPaymentContext(customerContext: STPCustomerContext(keyProvider: EphemeralKeyProvider.shared))

    // MARK: - IBOutlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var subtotalLabel: UILabel!
    @IBOutlet var taxLabel: UILabel!
    @IBOutlet var purchaseButton: UIButton!
    @IBOutlet var creditCardButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 100
        purchaseButton.layer.cornerRadius = 20
        updateUI()
        
        paymentContext.paymentAmount = viewModel.finalPrice.toCents()
        paymentContext.delegate = self
        paymentContext.hostViewController = self
        paymentContext.configuration.createCardSources = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    func updateUI() {
        subtotalLabel.text = viewModel.subtotalPrice.priceString
        taxLabel.text = viewModel.taxPrice.priceString
        purchaseButton.setTitle(viewModel.finalPrice.priceString, for: .normal)
    }
    
    func editItem(for food: Food) {
//        let itemsViewController = ItemsViewController.storyboardInstance() as! ItemsViewController
//        itemsViewController.salad = food as! Salad
//        itemsViewController.isEditingFood = true
//        itemsViewController.didFinishEditing = {
//            self.tableView.reloadData()
//            self.updateUI()
//            self.viewModel.finishEditing()
//        }
//        navigationController?.pushViewController(itemsViewController, animated: true)
    }
    
    func delete(_ food: Food) {
        if let indexPath = viewModel.indexPath(for: food) {
            var indexPathsToDelete = [indexPath]
            let nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
            // Append quantity cell to delete.
            if let nextKey = viewModel.item(for: nextIndexPath)?.key, nextKey == .quantity {
                indexPathsToDelete.append(nextIndexPath)
            }
            viewModel.remove(food) { didRemoveSection in
                if didRemoveSection {
                    self.tableView.deleteSections([indexPath.section], with: .fade)
                } else {
                    self.tableView.deleteRows(at: indexPathsToDelete, with: .automatic)
                }
                self.updateUI()
            }
        }
    }
    
    func clearBag() {
        viewModel.clearBag()
        tableView.reloadData()
        updateUI()
    }

    // MARK: - IBActions
    @IBAction func didTapPurchase(_ sender: UIButton) {
        paymentContext.requestPayment()
    }
    
    @IBAction func didTapClear(_ sender: UIButton) {
        clearBag()
    }
    
    @IBAction func didTapDone(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func test(_ sender: UIButton) {
        paymentContext.pushPaymentMethodsViewController()
    }
}

extension BagViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.item(for: indexPath)!
        switch item.key {
        case .food:
            let foodItem = item as! FoodBagItem
            let food = foodItem.food
            let cell = tableView.dequeueReusableCell(withIdentifier: foodItem.cellIdenitifier.rawValue, for: indexPath) as! FoodTableViewCell
            
            switch food {
            case let salad as Salad:
                cell.titleLabel.text = "\(salad.size!.name) Salad"
            default: break
            }
            
            cell.descriptionLabel.text = food.itemDescription
            cell.priceLabel.text = food.price.priceString
            
            cell.didEdit = { cell in
                self.editItem(for: food)
            }
            
            return cell
        case .quantity:
            let quantityItem = item as! QuantityBagItem
            var food = quantityItem.food
            let cell = tableView.dequeueReusableCell(withIdentifier: quantityItem.cellIdenitifier.rawValue, for: indexPath) as! ItemQuantityTableViewCell
            cell.quantityCollectionView.didSelectQuantity = { quantity in
                switch quantity {
                case .none:
                    self.delete(quantityItem.food)
                case .some(let amount):
                    food.quantity = amount
                    self.tableView.reloadData()
                    self.updateUI()
                    self.viewModel.finishEditing()
                }
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = viewModel.item(for: indexPath)!
        switch item.key {
        case .food:
            return UITableViewAutomaticDimension
        case .quantity:
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.item(for: indexPath)!
        switch item.key {
        case .food:
            let foodItem = item as! FoodBagItem
            let food = foodItem.food
            if let foodViewController = FoodViewController.storyboardInstance() as? FoodViewController {
                foodViewController.viewModel = FoodViewModel(food: food)
                foodViewController.didGoBack = { foodViewController in
                    self.tableView.reloadData()
                    self.updateUI()
                }
                navigationController?.pushViewController(foodViewController, animated: true)
            }
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let foodItem = viewModel.item(for: indexPath) as? FoodBagItem {
                delete(foodItem.food)
            }
        }
    }
}

extension BagViewController: STPPaymentContextDelegate {
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        
    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        guard let label = paymentContext.selectedPaymentMethod?.label else { return }
        creditCardButton.setTitle(label, for: .normal)
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        UserAPIClient.getCustomerID(for: UserDataStore.shared.user!) { result in
            switch result {
            case .success(let customerID):
                PayAPIClient.chargeSource(paymentResult.source.stripeID, amount: paymentContext.paymentAmount, customerID: customerID) { result in
                    switch result {
                    case .success:
                        completion(nil)
                    case .failure(let error):
                        completion(error)
                    }
                }
            case .failure: break
            }
        }
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        if let errorMessage = error?.localizedDescription {
            print(errorMessage)
        }
    }
}

extension Double {
    var priceString: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        return numberFormatter.string(from: NSNumber(value: self))!
    }
    
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded()/divisor
    }
}
