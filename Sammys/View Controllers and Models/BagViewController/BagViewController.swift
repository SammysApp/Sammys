//
//  BagViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/8/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import PromiseKit

class BagViewController: UIViewController {
	/// Must be set for use of the view model.
	var viewModelParcel: BagViewModelParcel!
	{ didSet { viewModel = BagViewModel(parcel: viewModelParcel, viewDelegate: self); viewModel.bagPurchasableTableViewCellDelegate = self } }
	var viewModel: BagViewModel!
	
	private var lastSelectedIndexPath: IndexPath?
	
	// MARK: - View Controllers
	lazy var paymentViewController: PaymentViewController = {
		let paymentViewController = PaymentViewController.storyboardInstance()
		paymentViewController.delegate = self
		return paymentViewController
	}()
	
	lazy var itemsViewController: ItemsViewController = {
		let itemsViewController = ItemsViewController.storyboardInstance()
		itemsViewController.delegate = self
		return itemsViewController
	}()
	
	lazy var builderViewController: BuilderViewController = {
		let builderViewController = BuilderViewController.storyboardInstance()
		builderViewController.delegate = self
		return builderViewController
	}()
	
    // MARK: - IBOutlets
	@IBOutlet var tableView: UITableView!
	@IBOutlet var paymentVisualEffectView: UIVisualEffectView!
	
	// MARK: - Property Overrides
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
	
	struct Constants {
		static let tableViewEstimatedRowHeight: CGFloat = 120
	}

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
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
		updatePaymentViewController()
		add(asChildViewController: paymentViewController)
		paymentViewController.view.translatesAutoresizingMaskIntoConstraints = false
		paymentViewController.view.fullViewConstraints(equalTo: paymentVisualEffectView).activateAll()
	}
	
	// MARK: - Update
	func updatePaymentViewController() {
		paymentViewController.viewModelParcel = PaymentViewModelParcel(subtotal: viewModel.subtotal, tax: viewModel.tax, total: viewModel.total)
	}
	
	// MARK: - Methods
	func delete(at indexPath: IndexPath) {
		do { try viewModel.delete(at: indexPath); tableView.deleteRows(at: [indexPath], with: .automatic) }
		catch { print(error) }
	}

    // MARK: - IBActions
    @IBAction func didTapClear(_ sender: UIBarButtonItem) {
		viewModel.clear()
		tableView.reloadData()
	}

    @IBAction func didTapDone(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
	
	// MARK: - Debug
	func noCellViewModelMessage(for indexPath: IndexPath) -> String {
		return "No cell view model for index path, \(indexPath)."
	}
	
	func cantDequeueCellMessage(forIdentifier identifier: String) -> String {
		return "Can't dequeue reusable cell with identifier, \(identifier)."
	}
}

// MARK: - Storyboardable
extension BagViewController: Storyboardable {}

// MARK: - BagViewModelViewDelegate
extension BagViewController: BagViewModelViewDelegate {
	func cellHeight() -> Double { return Double(Constants.tableViewEstimatedRowHeight) }
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
		guard let cellViewModel = viewModel.cellViewModel(for: indexPath) else { fatalError(noCellViewModelMessage(for: indexPath)) }
		guard let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.identifier) else { fatalError(cantDequeueCellMessage(forIdentifier: cellViewModel.identifier)) }
		cellViewModel.commands[.configuration]?.perform(parameters: TableViewCellCommandParameters(cell: cell))
        return cell
    }
}

// MARK: - UITableViewDelegate
extension BagViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		lastSelectedIndexPath = indexPath
		if let cellViewModel = viewModel.cellViewModel(for: indexPath),
			let itemedPurchasable = cellViewModel.purchasableQuantity.purchasable as? ItemedPurchasable {
			itemsViewController.viewModelParcel = ItemsViewModelParcel(itemedPurchasable: itemedPurchasable)
			navigationController?.pushViewController(itemsViewController, animated: true)
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

// MARK: - BagPurchasableTableViewCellDelegate
extension BagViewController: BagPurchasableTableViewCellDelegate {
	func bagPurchasableTableViewCell(_ cell: BagPurchasableTableViewCell, didChangeQuantityTo quantity: Int, at indexPath: IndexPath) {
		do {
			try viewModel.set(toQuantity: quantity, at: indexPath)
			handleQuantityUpdate(in: cell, at: indexPath) }
		catch { print(error) }
	}
	
	func bagPurchasableTableViewCell(_ cell: BagPurchasableTableViewCell, didDecrementQuantityAt indexPath: IndexPath) {
		do {
			try viewModel.decrementQuantity(at: indexPath)
			handleQuantityUpdate(in: cell, at: indexPath)
		} catch { print(error) }
	}
	
	func bagPurchasableTableViewCell(_ cell: BagPurchasableTableViewCell, didIncrementQuantityAt indexPath: IndexPath) {
		do {
			try viewModel.incrementQuantity(at: indexPath)
			handleQuantityUpdate(in: cell, at: indexPath)
		} catch { print(error) }
	}
	
	private func handleQuantityUpdate(in cell: BagPurchasableTableViewCell, at indexPath: IndexPath) {
		updatePaymentViewController()
		if let cellViewModel = viewModel.cellViewModel(for: indexPath) {
			updateQuantityTextField(cell.quantityTextField, forQuantity: cellViewModel.purchasableQuantity.quantity)
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

// MARK: - PaymentViewControllerDelegate
extension BagViewController: PaymentViewControllerDelegate {
	func paymentViewController(_ paymentViewController: PaymentViewController, didTapPayButton button: UIButton) {
		viewModel.completePurchase().catch { print($0) }
	}
}

// MARK: - ItemsViewControllerDelegate
extension BagViewController: ItemsViewControllerDelegate {
	func itemsViewController(_ itemsViewController: ItemsViewController, didSelectEdit itemCategory: ItemCategory, in itemedPurchasable: ItemedPurchasable) {
		guard let viewModelParcel = BuilderViewModelParcel.instance(for: itemedPurchasable) else { return }
		builderViewController.viewModelParcel = viewModelParcel
		itemsViewController.present(builderViewController, animated: true) {
			self.builderViewController.set(to: itemCategory)
		}
	}
}

// MARK: - BuilderViewControllerDelegate
extension BagViewController: BuilderViewControllerDelegate {
	func builderViewController(_ builderViewController: BuilderViewController, didFinishBuilding itemedPurchasable: ItemedPurchasable) {
		if let itemsViewController = (builderViewController.presentingViewController as? UINavigationController)?.topViewController as? ItemsViewController {
			itemsViewController.viewModelParcel = ItemsViewModelParcel(itemedPurchasable: itemedPurchasable)
			builderViewController.dismiss(animated: true, completion: nil)
		}
		
		if let selectedIndexPath = lastSelectedIndexPath {
			do {
				try viewModel.updatePurchasable(at: selectedIndexPath, to: itemedPurchasable)
				tableView.reloadData()
				updatePaymentViewController()
			} catch { print(error) }
		}
	}
}
