//
//  BagViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/8/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class BagViewController: UIViewController {
	lazy var viewModel = BagViewModel(self)
	
	lazy var paymentViewController = { return PaymentViewController.storyboardInstance() }()
	
    // MARK: - IBOutlets
	@IBOutlet var tableView: UITableView!
	@IBOutlet var paymentVisualEffectView: UIVisualEffectView!
	
	// MARK: - Property Overrides
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
	
	struct Constants {
		static let tableViewEstimatedRowHeight: CGFloat = 120
	}

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
		viewModel.bagPurchaseableTableViewCellDelegate = self
		
		setupViews()
    }
	
	// MARK: - Setup
	func setupViews() {
		setupTableView()
		setupChildPaymentViewController()
	}
	
	func setupTableView() {
		tableView.estimatedRowHeight = Constants.tableViewEstimatedRowHeight
		tableView.rowHeight = UITableViewAutomaticDimension
	}
	
	func setupChildPaymentViewController() {
		add(asChildViewController: paymentViewController)
		paymentViewController.view.translatesAutoresizingMaskIntoConstraints = false
		paymentViewController.view.fullViewConstraints(equalTo: paymentVisualEffectView).activateAll()
	}
	
	func delete(at indexPath: IndexPath) {
		do { try viewModel.delete(at: indexPath); tableView.deleteRows(at: [indexPath], with: .automatic) }
		catch { print(error) }
	}
	
	func foodViewController(for indexPath: IndexPath) -> FoodViewController? {
		guard let viewModelParcel = viewModel.foodViewModelParcel(for: indexPath) else { return nil }
		let foodViewController = FoodViewController.storyboardInstance()
		foodViewController.viewModelParcel = viewModelParcel
		foodViewController.delegate = self
		return foodViewController
	}

    // MARK: - IBActions
    @IBAction func didTapClear(_ sender: UIBarButtonItem) {
		viewModel.clear()
		tableView.reloadData()
	}

    @IBAction func didTapDone(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Storyboardable
extension BagViewController: Storyboardable {}

// MARK: - BagViewModelViewDelegate
extension BagViewController: BagViewModelViewDelegate {
	func cellHeight() -> Double { return 100 }
}

// MARK: - UITableViewDataSource
extension BagViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(inSection: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cellViewModel = viewModel.cellViewModel(for: indexPath) else { fatalError("No cell view model for index path, \(indexPath)") }
		guard let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.identifier) else { fatalError("No cell for identifier, \(cellViewModel.identifier).") }
		cellViewModel.commands[.configuration]?.perform(parameters: TableViewCellCommandParameters(cell: cell))
        return cell
    }
}

// MARK: - UITableViewDelegate
extension BagViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let foodViewController = foodViewController(for: indexPath) {
			navigationController?.pushViewController(foodViewController, animated: true)
		}
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		guard let cellViewModel = viewModel.cellViewModel(for: indexPath)
			else { return false }
		return cellViewModel.isEditable
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete { delete(at: indexPath) }
	}
}

// MARK: - BagPurchaseableTableViewCellDelegate
extension BagViewController: BagPurchaseableTableViewCellDelegate {
	func bagPurchaseableTableViewCell(_ cell: BagPurchaseableTableViewCell, didChangeQuantityTo quantity: Int, at indexPath: IndexPath) {
		do { try viewModel.set(toQuantity: quantity, at: indexPath); handleQuantityUpdate(in: cell, at: indexPath) }
		catch { print(error) }
	}
	
	func bagPurchaseableTableViewCell(_ cell: BagPurchaseableTableViewCell, didDecrementQuantityAt indexPath: IndexPath) {
		do { try viewModel.decrementQuantity(at: indexPath); handleQuantityUpdate(in: cell, at: indexPath) }
		catch { print(error) }
	}
	
	func bagPurchaseableTableViewCell(_ cell: BagPurchaseableTableViewCell, didIncrementQuantityAt indexPath: IndexPath) {
		do { try viewModel.incrementQuantity(at: indexPath); handleQuantityUpdate(in: cell, at: indexPath) }
		catch { print(error) }
	}
	
	private func handleQuantityUpdate(in cell: BagPurchaseableTableViewCell, at indexPath: IndexPath) {
		if let cellViewModel = viewModel.cellViewModel(for: indexPath) {
			updateQuantityTextField(cell.quantityTextField, forQuantity: cellViewModel.purchaseableQuantity.quantity)
		}
		// Assuming no more cell view model means cell was deleted.
		else { tableView.deleteRows(at: [indexPath], with: .automatic) }
	}
	
	private func updateQuantityTextField(_ quantityTextField: UITextField, forQuantity quantity: Int) {
		let quantityString = "\(quantity)"
		quantityTextField.placeholder = quantityString
		if let text = quantityTextField.text, !text.isEmpty { quantityTextField.text = quantityString }
	}
}

// MARK - FoodViewControllerDelegate
extension BagViewController: FoodViewControllerDelegate {
	func foodViewController(_ foodViewController: FoodViewController, didSelectEdit itemCategory: FoodItemCategory, in food: Food) {
		let itemsViewController = ItemsViewController.storyboardInstance()
		let foodType = type(of: food)
		itemsViewController.viewModelParcel = ItemsViewModelParcel(itemCategories: foodType.allItemCategories, dataFetcher: foodType.itemsDataFetcher, builder: foodType.builder.init())
		foodViewController.present(itemsViewController, animated: true, completion: nil)
	}
}
