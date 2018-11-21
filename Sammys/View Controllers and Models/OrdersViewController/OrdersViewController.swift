//
//  OrdersViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/18/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class OrdersViewController: UIViewController {
	/// Must be set for use of the view model.
	var viewModelParcel: OrdersViewModelParcel!
	{ didSet { viewModel = OrdersViewModel(parcel: viewModelParcel, viewDelegate: self) } }
	var viewModel: OrdersViewModel!
	
	// MARK: - IBOutlets
	@IBOutlet var tableView: UITableView!
	
	// MARK: - Property Overrides
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
	
	struct Constants {
		static let cellHeight: Double = 100
	}

	// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
		viewModel.setupData().get { self.loadViews() }.catch { print($0) }
    }
	
	// MARK: - Setup
	func loadViews() {
		tableView.reloadData()
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
extension OrdersViewController: Storyboardable {}

// MARK: - OrdersViewModelViewDelegate
extension OrdersViewController: OrdersViewModelViewDelegate {
	func cellHeight() -> Double { return Constants.cellHeight }
}

// MARK: - UITableViewDataSource
extension OrdersViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return viewModel.numberOfSections
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfRows(inSection: section)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cellViewModel = viewModel.cellViewModel(for: indexPath)
			else { fatalError(noCellViewModelMessage(for: indexPath)) }
		guard let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.identifier)
			else { fatalError(cantDequeueCellMessage(forIdentifier: cellViewModel.identifier)) }
		cellViewModel.commands[.configuration]?.perform(parameters: TableViewCellCommandParameters(cell: cell))
		return cell
	}
}

// MARK: - UITableViewDelegate
extension OrdersViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		guard let cellViewModel = viewModel.cellViewModel(for: indexPath)
			else { fatalError(noCellViewModelMessage(for: indexPath)) }
		return CGFloat(cellViewModel.height)
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let cellViewModel = viewModel.cellViewModel(for: indexPath) else { return }
		let orderViewController = OrderViewController.storyboardInstance()
		orderViewController.viewModelParcel = OrderViewModelParcel(order: cellViewModel.order)
		navigationController?.pushViewController(orderViewController, animated: true)
	}
}
