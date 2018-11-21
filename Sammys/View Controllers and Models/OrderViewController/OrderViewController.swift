//
//  OrderViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/24/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class OrderViewController: UIViewController {
	/// Must be set for use by the view model.
	var viewModelParcel: OrderViewModelParcel!
    lazy var viewModel = OrderViewModel(parcel: viewModelParcel, viewDelegate: self)
    
    // MARK: - IBOutlets
    @IBOutlet var tableView: UITableView!
	
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
	}
	
	func setupTableView() {
		tableView.estimatedRowHeight = Constants.tableViewEstimatedRowHeight
		tableView.rowHeight = UITableViewAutomaticDimension
	}
	
	func noCellViewModelMessage(for indexPath: IndexPath) -> String {
		return "No cell view model for index path, \(indexPath)"
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
			else { fatalError("No cell for identifier, \(cellViewModel.identifier).") }
		cellViewModel.commands[.configuration]?.perform(parameters: TableViewCellCommandParameters(cell: cell))
		return cell
	}
}
