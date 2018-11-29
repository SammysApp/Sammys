//
//  ActiveOrderViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/28/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import CoreLocation

protocol ActiveOrderViewControllerDelegate {
	func activeOrderViewControllerDidTapDone(_ activeOrderViewController: ActiveOrderViewController)
}

class ActiveOrderViewController: UIViewController {
	var viewModelParcel: ActiveOrderViewModelParcel?
		{ didSet { viewModel.parcel = viewModelParcel } }
	lazy var viewModel = ActiveOrderViewModel(parcel: viewModelParcel, viewDelegate: self)
	
	var delegate: ActiveOrderViewControllerDelegate?
	
	// MARK: - View Controllers
	lazy var orderViewController = { OrderViewController.storyboardInstance() }()
	
	// MARK: - IBOutlets
	@IBOutlet var tableView: UITableView!
	
	struct Constants {
		static let mapCellHeight: CGFloat = 150
		static let wazeBaseURL = "waze://"
		static let googleMapsBaseURL = "comgooglemaps://"
		static let mapsActionTitle = "Maps"
		static let googleMapsActionTitle = "Google Maps"
		static let wazeActionTitle = "Waze"
		static let mapsName = "Sammy's"
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
	
	// MARK: - Methods
	func openInMapsAction(for coordinates: CLLocationCoordinate2D) -> UIAlertAction {
		return UIAlertAction(title: Constants.mapsActionTitle, style: .default) { _ in coordinates.openInMaps(withName: Constants.mapsName) }
	}
	
	func openInGoogleMapsAction(for coordinates: CLLocationCoordinate2D) -> UIAlertAction? {
		guard URL.canOpen(Constants.googleMapsBaseURL) else { return nil }
		return UIAlertAction(title: Constants.googleMapsActionTitle, style: .default) { _ in coordinates.openInGoogleMaps() }
	}
	
	func navigateInWazeAction(for coordinates: CLLocationCoordinate2D) -> UIAlertAction? {
		guard URL.canOpen(Constants.wazeBaseURL) else { return nil }
		return UIAlertAction(title: Constants.wazeActionTitle, style: .default) { _ in coordinates.navigateInWaze() }
	}
	
	func cancelAction(in alertController: UIAlertController) -> UIAlertAction {
		return UIAlertAction(title: "Cancel", style: .cancel) { _ in alertController.dismiss(animated: true, completion: nil) }
	}
	
	func presentNavigationAlert() throws {
		let navigationAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		let appData = try AppData.get()
		let coordinates = CLLocationCoordinate2D(latitude: appData.sammys.latitude, longitude: appData.sammys.longitude)
		[openInMapsAction(for: coordinates),
		 openInGoogleMapsAction(for: coordinates),
		 navigateInWazeAction(for: coordinates),
		 cancelAction(in: navigationAlertController)].forEach
			{ if let action = $0 { navigationAlertController.addAction(action) } }
		present(navigationAlertController, animated: true, completion: nil)
	}
	
	// MARK: - IBActions
	@IBAction func didTapDone(_ sender: UIBarButtonItem) {
		delegate?.activeOrderViewControllerDidTapDone(self)
	}
	
	// MARK: - Debug
	func noCellViewModelMessage(for indexPath: IndexPath) -> String {
		return "No cell view model for index path, \(indexPath)."
	}
	
	func cantDequeueCellMessage(forIdentifier identifier: String) -> String {
		return "Can't dequeue reusable cell with identifier, \(identifier)."
	}
}

// MARK: - ActiveOrderViewController
extension ActiveOrderViewController: Delegatable {}

// MARK: - Storyboardable
extension ActiveOrderViewController: Storyboardable {}

// MARK: - ActiveOrderViewModelViewDelegate
extension ActiveOrderViewController: ActiveOrderViewModelViewDelegate {
	func cellHeight(for cellIdentifier: ActiveOrderCellIdentifier) -> Double {
		switch cellIdentifier {
		case .orderCell: return Double(orderViewController.tableView.contentSize.height)
		default: return Double(Constants.mapCellHeight)
		}
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
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		viewModel
			.cellViewModel(for: indexPath)?
			.commands[.selection]?
			.perform(parameters: TableViewCellCommandParameters(viewController: self))
	}
}
