//
//  BagViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/8/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import Stripe

class BagViewController: UIViewController, BagViewModelDelegate, Storyboardable {
    typealias ViewController = BagViewController
    
    let viewModel = BagViewModel()

    // MARK: - IBOutlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var subtotalLabel: UILabel!
    @IBOutlet var taxLabel: UILabel!
    @IBOutlet var purchaseButton: UIButton!
    @IBOutlet var creditCardButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        
        tableView.estimatedRowHeight = 100
        purchaseButton.layer.cornerRadius = 20
        updateUI()
        updatePaymentPrice()
        
        viewModel.paymentContext.hostViewController = self
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
    
    func updatePaymentPrice() {
        viewModel.paymentContext.paymentAmount = viewModel.finalPrice.toCents()
    }
    
    func didEdit(_ food: Food) {
        let itemsViewController = ItemsViewController.storyboardInstance() as! ItemsViewController
        itemsViewController.resetFood(to: food)
        itemsViewController.isEditingFood = true
        itemsViewController.didFinishEditing = {
            self.tableView.reloadData()
            self.updateUI()
            self.updatePaymentPrice()
            self.viewModel.finishEditing()
        }
        navigationController?.pushViewController(itemsViewController, animated: true)
    }
    
    func delete(at indexPath: IndexPath) {
        viewModel.remove(at: indexPath) { didRemoveSection in
            if didRemoveSection {
                self.tableView.deleteSections([indexPath.section], with: .fade)
            } else {
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            self.updateUI()
            self.updatePaymentPrice()
        }
    }
    
    func clearBag() {
        viewModel.clearBag()
        tableView.reloadData()
        updateUI()
        updatePaymentPrice()
    }
    
    func attemptPurchase() {
        presentConfirmationViewController()
//        if viewModel.user != nil {
//            viewModel.paymentContext.requestPayment()
//        } else {
//            let vc = STPAddCardViewController()
//            vc.delegate = self
//            navigationController?.pushViewController(vc, animated: true)
//        }
    }
    
    func paymentDidComplete(with paymentResult: PaymentResult) {
        switch paymentResult {
        case .success: presentConfirmationViewController()
        case .failure(let message): print(message)
        }
    }
    
    func cellViewModel(for indexPath: IndexPath) -> TableViewCellViewModel {
        return viewModel.cellViewModels(in: indexPath.section)[indexPath.row]
    }
    
    func presentConfirmationViewController() {
        present(ConfirmationViewController.storyboardInstance(), animated: true, completion: nil)
    }

    // MARK: - IBActions
    @IBAction func didTapPurchase(_ sender: UIButton) {
        attemptPurchase()
    }
    
    @IBAction func didTapClear(_ sender: UIButton) {
        clearBag()
    }
    
    @IBAction func didTapDone(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func test(_ sender: UIButton) {
        viewModel.paymentContext.pushPaymentMethodsViewController()
    }
}

// MARK: - UITableViewDataSource
extension BagViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = cellViewModel(for: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: model.identifier)!
        model.commands[.configuration]?.perform(cell: cell)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension BagViewController: UITableViewDelegate {
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
                    self.updatePaymentPrice()
                }
                navigationController?.pushViewController(foodViewController, animated: true)
            }
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            delete(at: indexPath)
        }
    }
}

extension BagViewController: STPAddCardViewControllerDelegate {
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateSource source: STPSource, completion: @escaping STPErrorBlock) {
        viewModel.chargeSource(with: source.stripeID, completed: completion)
    }
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        navigationController?.popViewController(animated: true)
    }
}
