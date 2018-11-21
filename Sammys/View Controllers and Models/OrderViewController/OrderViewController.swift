//
//  OrderViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/24/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class OrderViewController: UIViewController {
	/// Must be set for use of the view model.
	var viewModelParcel: OrderViewModelParcel!
	{ didSet { viewModel = OrderViewModel(parcel: viewModelParcel, viewDelegate: self) } }
	var viewModel: OrderViewModel!
    
    // MARK: - IBOutlets
    @IBOutlet var tableView: UITableView!
	@IBOutlet var priceView: UIView!
	@IBOutlet var subtotalLabel: UILabel!
	@IBOutlet var taxLabel: UILabel!
	@IBOutlet var totalLabel: UILabel!
	
	// MARK: - Property Overrides
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
	
	private struct Constants {
		static var tableViewEstimatedRowHeight: CGFloat = 100
	}
	
	// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupViews()
    }
	
	// MARK: - Setup
	func setupViews() {
		setupTableView()
		setupPriceView()
	}
	
	func setupTableView() {
		tableView.estimatedRowHeight = Constants.tableViewEstimatedRowHeight
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.tableFooterView = priceView
	}
	
	func setupPriceView() {
		subtotalLabel.text = viewModel.subtotalText
		taxLabel.text = viewModel.taxText
		totalLabel.text = viewModel.totalText
	}
	
	// MARK: - Debug
	func noCellViewModelMessage(for indexPath: IndexPath) -> String {
		return "No cell view model for index path, \(indexPath)"
	}
	
	func cantDequeueCellMessage(forIdentifier identifier: String) -> String {
		return "Can't dequeue reusable cell with identifier: \(identifier)"
	}
}

// MARK: - Storyboardable
extension OrderViewController: Storyboardable {}

// MARK: - OrderViewModelViewDelegate
extension OrderViewController: OrderViewModelViewDelegate {
	func cellHeight() -> Double { return Double(Constants.tableViewEstimatedRowHeight) }
}

// MARK: - UITableViewDataSource
extension OrderViewController: UITableViewDataSource {
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
