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
	
    // MARK: - IBOutlets
	@IBOutlet var tableView: UITableView!

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
	}
	
	func setupTableView() {
		tableView.estimatedRowHeight = Constants.tableViewEstimatedRowHeight
		tableView.rowHeight = UITableViewAutomaticDimension
	}
	
	func delete(at indexPath: IndexPath) {
		do {
			try viewModel.delete(at: indexPath)
			tableView.deleteRows(at: [indexPath], with: .automatic)
		}
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
        let cellViewModel = viewModel.cellViewModel(for: indexPath)
		guard let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.identifier) else { fatalError("No cell for identifier, \(cellViewModel.identifier).") }
		cellViewModel.commands[.configuration]?.perform(parameters: TableViewCellCommandParameters(cell: cell))
        return cell
    }
}

// MARK: - UITableViewDelegate
extension BagViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		let cellViewModel = viewModel.cellViewModel(for: indexPath)
		return cellViewModel.isEditable
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete { delete(at: indexPath) }
	}
}

// MARK: - BagPurchaseableTableViewCellDelegate
extension BagViewController: BagPurchaseableTableViewCellDelegate {
	func bagPurchaseableTableViewCell(_ cell: BagPurchaseableTableViewCell, didDecrementQuantityAt indexPath: IndexPath) {
		do { try viewModel.decrement(at: indexPath); tableView.reloadData() } catch { print(error) }
	}
	
	func bagPurchaseableTableViewCell(_ cell: BagPurchaseableTableViewCell, didIncrementQuantityAt indexPath: IndexPath) {
		do { try viewModel.increment(at: indexPath); tableView.reloadData() } catch { print(error) }
	}
}
