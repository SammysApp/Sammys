//
//  BagViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/8/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class BagViewController: UIViewController {
	/// Must be set for use by the view model.
	var viewModelParcel: BagViewModelParcel!
	private lazy var viewModel = BagViewModel(parcel: viewModelParcel, viewDelegate: self)
	
	lazy var paymentViewController: PaymentViewController = {
		let paymentViewController = PaymentViewController.storyboardInstance()
		paymentViewController.delegate = self
		return paymentViewController
	}()
	
	private var lastSelectedIndexPath: IndexPath?
	
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
		
		viewModel.bagPurchasableTableViewCellDelegate = self
		
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
		do {
			try updatePaymentViewController()
			add(asChildViewController: paymentViewController)
			paymentViewController.view.translatesAutoresizingMaskIntoConstraints = false
			paymentViewController.view.fullViewConstraints(equalTo: paymentVisualEffectView).activateAll()
		} catch { print(error) }
	}
	
	func updatePaymentViewController() throws {
		do { paymentViewController.viewModelParcel = try viewModel.paymentViewModelParcel() }
		catch { throw error }
	}
	
	func delete(at indexPath: IndexPath) {
		do { try viewModel.delete(at: indexPath); tableView.deleteRows(at: [indexPath], with: .automatic) }
		catch { print(error) }
	}
	
	func itemsViewController(for indexPath: IndexPath) -> ItemsViewController? {
		guard let viewModelParcel = viewModel.itemsViewModelParcel(for: indexPath) else { return nil }
		let itemsViewController = ItemsViewController.storyboardInstance()
		itemsViewController.viewModelParcel = viewModelParcel
		itemsViewController.delegate = self
		return itemsViewController
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
		lastSelectedIndexPath = indexPath
		if let itemsViewController = itemsViewController(for: indexPath) {
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
		do { try viewModel.set(toQuantity: quantity, at: indexPath); handleQuantityUpdate(in: cell, at: indexPath) }
		catch { print(error) }
	}
	
	func bagPurchasableTableViewCell(_ cell: BagPurchasableTableViewCell, didDecrementQuantityAt indexPath: IndexPath) {
		do { try viewModel.decrementQuantity(at: indexPath); handleQuantityUpdate(in: cell, at: indexPath) }
		catch { print(error) }
	}
	
	func bagPurchasableTableViewCell(_ cell: BagPurchasableTableViewCell, didIncrementQuantityAt indexPath: IndexPath) {
		do { try viewModel.incrementQuantity(at: indexPath); handleQuantityUpdate(in: cell, at: indexPath) }
		catch { print(error) }
	}
	
	private func handleQuantityUpdate(in cell: BagPurchasableTableViewCell, at indexPath: IndexPath) {
		do { try updatePaymentViewController() } catch { print(error) }
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

extension BagViewController: PaymentViewControllerDelegate {
	func paymentViewController(_ paymentViewController: PaymentViewController, didTapPayButton button: UIButton) {
		viewModel.sendOrder().catch { print($0) }
	}
}

// MARK: - ItemsViewControllerDelegate
extension BagViewController: ItemsViewControllerDelegate {
	func itemsViewController(_ itemsViewController: ItemsViewController, didSelectEdit itemCategory: ItemCategory, in itemedPurchasable: ItemedPurchasable) {
		let builderViewController = BuilderViewController.storyboardInstance()
		builderViewController.viewModelParcel = BuilderViewModelParcel.instance(for: type(of: itemedPurchasable))
		do { try builderViewController.viewModelParcel.builder.toggleExisting(from: itemedPurchasable) } catch { print(error); return }
		builderViewController.delegate = self
		itemsViewController.present(builderViewController, animated: true, completion: nil)
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
				try updatePaymentViewController()
			}
			catch { print(error) }
		}
	}
}
