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
    
    private struct Constants {
        static let checkoutAlertMessage = "Choose the way you would like to checkout."
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        
        tableView.estimatedRowHeight = 100
        purchaseButton.layer.cornerRadius = 20
        updateUI()
        
        viewModel.updatePaymentPrice()
        viewModel.paymentContextHostViewController = self
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
            self.viewModel.updatePaymentPrice()
            self.viewModel.saveBag()
        }
        navigationController?.pushViewController(itemsViewController, animated: true)
    }
    
    func delete(sections: IndexSet) {
        tableView.deleteSections(sections, with: .fade)
        updateUI()
        viewModel.updatePaymentPrice()
    }
    
    func delete(indexPaths: [IndexPath]) {
        tableView.deleteRows(at: indexPaths, with: .automatic)
        updateUI()
        viewModel.updatePaymentPrice()
    }
    
    func delete(at indexPath: IndexPath) {
        viewModel.removeFood(at: indexPath)
    }
    
    func clearBag() {
        viewModel.clearBag()
        tableView.reloadData()
        updateUI()
        viewModel.updatePaymentPrice()
    }
    
    func attemptPurchase() {
        if viewModel.user == nil {
            presentCheckoutAlertController(
                didChooseGuest: pushAddCardViewController,
                didChooseCustomer: presentLoginPageViewController
            )
        } else {
            viewModel.requestPayment()
        }
    }
    
    func paymentDidComplete(with paymentResult: PaymentResult) {
        switch paymentResult {
        case .success:
            presentConfirmationViewController()
            viewModel.addToUserOrders()
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
            self.viewModel.updatePaymentPrice()
        }
        navigationController?.pushViewController(foodViewController, animated: true)
    }
    
    func presentCheckoutAlertController(didChooseGuest: @escaping () -> Void, didChooseCustomer: @escaping () -> Void) {
        let checkoutAlertController = UIAlertController(title: nil, message: Constants.checkoutAlertMessage, preferredStyle: .alert)
        [UIAlertAction(title: "Guest", style: .default, handler: { action in
            didChooseGuest()
        }),
        UIAlertAction(title: "Customer", style: .default, handler: { action in
            didChooseCustomer()
        }),
        UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            checkoutAlertController.dismiss(animated: true, completion: nil)
        })].forEach { checkoutAlertController.addAction($0) }
        present(checkoutAlertController, animated: true, completion: nil)
    }
    
    func presentLoginPageViewController() {
        let loginPageViewController = LoginPageViewController.storyboardInstance() as! LoginPageViewController
        loginPageViewController.delegate = self
        present(loginPageViewController, animated: true, completion: nil)
    }
    
    func pushAddCardViewController() {
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self
        self.navigationController?.pushViewController(addCardViewController, animated: true)
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
        viewModel.pushPaymentMethodsViewController()
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

// MARK: - LoginPageViewControllerDelegate
extension BagViewController: LoginPageViewControllerDelegate {
    func loginPageViewControllerDidLogin(_ loginPageViewController: LoginPageViewController) {
        viewModel.setupPaymentContext()
    }
    
    func loginPageViewControllerDidCancel(_ loginPageViewController: LoginPageViewController) {}
}

// MARK: - STPAddCardViewControllerDelegate
extension BagViewController: STPAddCardViewControllerDelegate {
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateSource source: STPSource, completion: @escaping STPErrorBlock) {
        viewModel.chargeSource(with: source.stripeID, completed: completion)
    }
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        navigationController?.popViewController(animated: true)
    }
}
