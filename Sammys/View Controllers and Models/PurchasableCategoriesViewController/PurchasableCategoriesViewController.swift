//
//  PurchasableCategoriesViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 12/11/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class PurchasableCategoriesViewController: UIViewController {
	var viewModelParcel: PurchasableCategoriesViewModelParcel?
	lazy var viewModel = PurchasableCategoriesViewModel(parcel: viewModelParcel, viewDelegate: self)
	
	struct Constants {
		static let tableViewCellHeight: CGFloat = 120
	}
	
	// MARK: - IBOutlets
	@IBOutlet var tableView: UITableView!
	
	// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.setNavigationBarHidden(false, animated: true)
	}
}

// MARK: - Storyboardable
extension PurchasableCategoriesViewController: Storyboardable {}

// MARK: - PurchasableCategoriesViewModelViewDelegate
extension PurchasableCategoriesViewController: PurchasableCategoriesViewModelViewDelegate {
	func cellHeight() -> Double { return Double(Constants.tableViewCellHeight) }
}

// MARK: - UITableViewDataSource
extension PurchasableCategoriesViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return viewModel.numberOfSections
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfRows(inSection: section)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cellViewModel = viewModel.cellViewModel(for: indexPath),
			let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.identifier) else { return UITableViewCell() }
		cellViewModel.commands[.configuration]?.perform(parameters: TableViewCellCommandParameters(cell: cell))
		return cell
	}
}

// MARK: - UITableViewDelegate
extension PurchasableCategoriesViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return CGFloat(viewModel.cellViewModel(for: indexPath)?.height ?? 0)
	}
}
