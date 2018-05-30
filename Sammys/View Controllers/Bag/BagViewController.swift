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
    @IBOutlet var paymentStackView: UIStackView!
    @IBOutlet var subtotalLabel: UILabel!
    @IBOutlet var taxLabel: UILabel!
    @IBOutlet var purchaseButton: UIButton!
    @IBOutlet var creditCardButton: UIButton!
    @IBOutlet var totalVisualEffectView: UIVisualEffectView!
    @IBOutlet var totalVisualEffectViewContainerView: UIView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private struct Constants {
        static let checkoutAlertMessage = "Choose the way you would like to checkout."
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        
        tableView.estimatedRowHeight = 100
        tableView.contentInset.bottom = totalVisualEffectView.frame.height
        tableView.separatorInset.bottom = totalVisualEffectView.frame.height
        purchaseButton.layer.cornerRadius = 20
        updateUI()
        
        viewModel.updatePaymentPrice()
        viewModel.paymentContextHostViewController = self
        
        let maskShape = CAShapeLayer()
        maskShape.bounds = totalVisualEffectView.frame
        maskShape.position = totalVisualEffectView.center
        maskShape.path = UIBezierPath(roundedRect: totalVisualEffectView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 40, height: 40)).cgPath
        totalVisualEffectView.layer.mask = maskShape
        
        totalVisualEffectViewContainerView.layer.masksToBounds = false
        totalVisualEffectViewContainerView.add(UIView.Shadow(path: UIBezierPath(roundedRect: totalVisualEffectViewContainerView.bounds, cornerRadius: 40).cgPath, radius: 10, opacity: 0.1))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    func updateUI() {
        subtotalLabel.text = viewModel.subtotalPrice.priceString
        taxLabel.text = viewModel.taxPrice.priceString
        purchaseButton.setTitle(viewModel.totalPrice.priceString, for: .normal)
        updatePaymentUI()
    }
    
    func updatePaymentUI() {
        creditCardButton.isHidden = viewModel.shouldHideCreditCardButton
        paymentStackView.spacing = viewModel.paymentStackViewSpacing
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
    
    func didFave(food: Food) {
        viewModel.fave(food)
    }
    
    func delete(sections: IndexSet) {
        tableView.deleteSections(sections, with: .automatic)
        updateUI()
        viewModel.updatePaymentPrice()
    }
    
    func delete(indexPaths: [IndexPath]) {
        tableView.deleteRows(at: indexPaths, with: .automatic)
        updateUI()
        viewModel.updatePaymentPrice()
    }
    
    func delete(at indexPath: IndexPath) {
        viewModel.remove(at: indexPath)
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
                didChooseGuest: presentAddCardViewController,
                didChooseCustomer: presentLoginPageViewController
            )
        } else {
            viewModel.requestPayment()
        }
    }
    
    func paymentMethodDidChange(_ paymentMethod: STPPaymentMethod) {
        creditCardButton.setTitle(paymentMethod.label, for: .normal)
    }
    
    func paymentDidComplete(with paymentResult: PaymentResult) {
        switch paymentResult {
        case .success:
            presentConfirmationViewController()
            viewModel.addToOrders()
            clearBag()
        case .failure(let message): print(message)
        }
    }
    
    func presentConfirmationViewController() {
        let confirmationViewController = ConfirmationViewController.storyboardInstance() as! ConfirmationViewController
        let navigationViewController = UINavigationController(rootViewController: confirmationViewController)
        confirmationViewController.delegate = self
        present(navigationViewController, animated: true, completion: nil)
    }
    
    func pushFoodViewController(for food: Food) {
        guard let foodViewController = FoodViewController.storyboardInstance() as? FoodViewController else { return }
        foodViewController.viewModel = FoodViewModel(food: food)
        foodViewController.didGoBack = { foodViewController in
            self.tableView.reloadData()
            self.updateUI()
            self.viewModel.updatePaymentPrice()
            self.viewModel.saveBag()
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
    
    func presentAddCardViewController() {
        let theme = STPTheme()
        theme.accentColor = #colorLiteral(red: 0.3333333333, green: 0.3019607843, blue: 0.2745098039, alpha: 1)
        theme.primaryBackgroundColor = #colorLiteral(red: 1, green: 0.968627451, blue: 0.9411764706, alpha: 1)
        let configuration = STPPaymentConfiguration()
        let addCardViewController = STPAddCardViewController(configuration: configuration, theme: theme)
        addCardViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: addCardViewController)
        present(navigationController, animated: true, completion: nil)
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
    
    @IBAction func didTapCreditCard(_ sender: UIButton) {
        viewModel.presentPaymentMethodsViewController()
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
        updateUI()
    }
    
    func loginPageViewControllerDidCancel(_ loginPageViewController: LoginPageViewController) {}
}

extension BagViewController: ConfirmationViewControllerDelegate {
    func confirmationViewControllerDidDismiss(_ confirmationViewController: ConfirmationViewController) {
        dismiss(animated: true, completion: nil)
    }
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
