//
//  OrdersViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/18/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class OrdersViewController: UIViewController {
	/// Must be set for use by the view model.
	var viewModelParcel: OrdersViewModelParcel!
	lazy var viewModel = OrdersViewModel(parcel: viewModelParcel, viewDelegate: self)
	
	// MARK: - IBOutlets
	@IBOutlet var tableView: UITableView!
	
	// MARK: - Property Overrides
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
	
	struct Constants {
		static let cellHeight: Double = 60
	}

	// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
		viewModel.setupData().get { self.loadViews() }.catch { print($0) }
    }
	
	func loadViews() {
		tableView.reloadData()
	}
	
	func noCellViewModelMessage(for indexPath: IndexPath) -> String {
		return "No cell view model for index path, \(indexPath)"
	}
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
			else { fatalError("No cell for identifier, \(cellViewModel.identifier).") }
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
}

// MARK: - Storyboardable
extension OrdersViewController: Storyboardable {}

// MARK: - OrdersViewModelViewDelegate
extension OrdersViewController: OrdersViewModelViewDelegate {
	func cellHeight() -> Double { return Constants.cellHeight }
}
