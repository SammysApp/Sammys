//
//  ActiveOrderViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/28/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class ActiveOrderViewController: UIViewController {
	/// Must be set for use of the view model.
	var viewModelParcel: ActiveOrderViewModelParcel!
		{ didSet { viewModel = ActiveOrderViewModel(parcel: viewModelParcel, viewDelegate: self) } }
	var viewModel: ActiveOrderViewModel!
	
	// MARK: - View Controllers
	lazy var orderViewController = { OrderViewController.storyboardInstance() }()
	
	// MARK: - IBOutlets
	@IBOutlet var tableView: UITableView!
	
	struct Constants {
		static let tableViewEstimatedRowHeight: CGFloat = 100
	}
	
	// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupViews()
    }
	
	// MARK: - Setup
	func setupViews() {
		setupTableView()
		setupChildOrderViewController()
	}
	
	func setupTableView() {
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: ActiveOrderCellIdentifier.orderCell.rawValue)
	}
	
	func setupChildOrderViewController() {
		addChildViewController(orderViewController)
		orderViewController.view.translatesAutoresizingMaskIntoConstraints = false
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
extension ActiveOrderViewController: Storyboardable {}

// MARK: - ActiveOrderViewModelViewDelegate
extension ActiveOrderViewController: ActiveOrderViewModelViewDelegate {
	func cellHeight() -> Double {
		return Double(orderViewController.tableView.contentSize.height)
	}
}

// MARK: - UITableViewDataSource
extension ActiveOrderViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return viewModel.numberOfSections
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfRows(inSection: section)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cellViewModel = viewModel.cellViewModel(for: indexPath) else { fatalError(noCellViewModelMessage(for: indexPath)) }
		guard let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.identifier) else { fatalError(cantDequeueCellMessage(forIdentifier: cellViewModel.identifier)) }
		cellViewModel.commands[.configuration]?.perform(parameters: TableViewCellCommandParameters(cell: cell, viewController: self))
		return cell
	}
}

// MARK: - UITableViewDelegate
extension ActiveOrderViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		guard let cellViewModel = viewModel.cellViewModel(for: indexPath) else { fatalError(noCellViewModelMessage(for: indexPath)) }
		return CGFloat(cellViewModel.height)
	}
}
