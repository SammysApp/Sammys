//
//  PurchasablesViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 12/5/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class PurchasablesViewController: UIViewController {
	var viewModelParcel: PurchasablesViewModelParcel?
		{ didSet { viewModel.parcel = viewModelParcel } }
	lazy var viewModel = PurchasablesViewModel(parcel: viewModelParcel, viewDelegate: self)
	
	// MARK: - IBOutlets
	@IBOutlet var tableView: UITableView!
	
	struct Constants {
		static let tableViewEstimatedRowHeight: CGFloat = 120
	}
	
	// MARK: - Lifecylce
    override func viewDidLoad() {
        super.viewDidLoad()
		
		viewModel.setupData()
			.get { self.tableView.reloadData() }.catch { print($0) }
    }
	
	// MARK: - Setup
	func setupTableView() {
		tableView.estimatedRowHeight = Constants.tableViewEstimatedRowHeight
		tableView.rowHeight = UITableViewAutomaticDimension
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
extension PurchasablesViewController: Storyboardable {}

// MARK: - PurchasablesViewModelViewDelegate
extension PurchasablesViewController: PurchasablesViewModelViewDelegate {
	func cellHeight() -> Double { return Double(Constants.tableViewEstimatedRowHeight) }
}

// MARK: - UITableViewDataSource
extension PurchasablesViewController: UITableViewDataSource {
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
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return viewModel.title(forSection: section)
	}
}

// MARK: - UITableViewDelegate
extension PurchasablesViewController: UITableViewDelegate {}
