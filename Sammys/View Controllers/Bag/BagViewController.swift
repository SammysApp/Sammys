//
//  BagViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/8/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import Stripe

class BagViewController: UIViewController, BagViewModelDelegate {
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
        purchaseButton.setTitle(viewModel.totalPrice.priceString, for: .normal)
    }
    
    func bagDataDidChange() {
        tableView.reloadData()
        updateUI()
    }
    
    func updatePaymentPrice() {
        viewModel.paymentContext.paymentAmount = viewModel.totalPrice.toCents()
    }
    
    func didSelect(food: Food) {
        pushFoodViewController(for: food)
    }
    
    func didEdit(food: Food) {
        let itemsViewController = ItemsViewController.storyboardInstance() as! ItemsViewController
        itemsViewController.resetFood(to: food)
        itemsViewController.isEditingFood = true
        itemsViewController.didFinishEditing = {
            self.tableView.reloadData()
            self.updateUI()
            self.updatePaymentPrice()
            self.viewModel.saveBag()
        }
        navigationController?.pushViewController(itemsViewController, animated: true)
    }
    
    func delete(sections: IndexSet) {
        tableView.deleteSections(sections, with: .fade)
        updateUI()
        updatePaymentPrice()
    }
    
    func delete(indexPaths: [IndexPath]) {
        tableView.deleteRows(at: indexPaths, with: .automatic)
        updateUI()
        updatePaymentPrice()
    }
    
    func delete(at indexPath: IndexPath) {
        viewModel.removeFood(at: indexPath)
    }
    
    func clearBag() {
        viewModel.clearBag()
        tableView.reloadData()
        updateUI()
        updatePaymentPrice()
    }
    
    func attemptPurchase() {
        viewModel.addToUserOrders()
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
    
    func presentConfirmationViewController() {
        present(ConfirmationViewController.storyboardInstance(), animated: true, completion: nil)
    }
    
    func pushFoodViewController(for food: Food) {
        guard let foodViewController = FoodViewController.storyboardInstance() as? FoodViewController else { return }
        foodViewController.viewModel = FoodViewModel(food: food)
        foodViewController.didGoBack = { foodViewController in
            self.tableView.reloadData()
            self.updateUI()
            self.updatePaymentPrice()
        }
        navigationController?.pushViewController(foodViewController, animated: true)
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

extension BagViewController: Storyboardable {
    typealias ViewController = BagViewController
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
        let cellViewModel = viewModel.cellViewModel(for: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.identifier)!
        cellViewModel.commands[.configuration]?.perform(cell: cell)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension BagViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellViewModel = viewModel.cellViewModel(for: indexPath)
        return cellViewModel.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let cellViewModel = viewModel.cellViewModel(for: indexPath)
        cellViewModel.commands[.selection]?.perform(cell: cell)
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
