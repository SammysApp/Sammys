//
//  ConfirmationViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/12/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ConfirmationViewController: UIViewController, Storyboardable {
    typealias ViewController = ConfirmationViewController
    
    let viewModel = ConfirmationViewModel()
    var cellViewModels = [CollectionViewCellViewModel]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    struct Constants {
        static let sammysCoordinates = CLLocationCoordinate2D(latitude: 40.902340, longitude: -74.004410)
        static let sammys = "Sammy's"
        static let maps = "Maps"
        static let waze = "Waze"
        static let googleMaps = "Google Maps"
        static let wazeBaseURL = "waze://"
        static let googleMapsBaseURL = "comgooglemaps://"
    }
    
    // MARK: - IBOutlets
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cellViewModels = viewModel.cellViewModels(for: view.bounds)
    }
    
    func presentNavigationAlert() {
        let navigationAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        // Add Maps action.
        navigationAlertController.addAction(
            UIAlertAction(title: Constants.maps, style: .default) { action in
            Constants.sammysCoordinates.openInMaps()
            })
        // Add Google Maps action if user has downloaded.
        if URL.canOpen(Constants.googleMapsBaseURL) {
            navigationAlertController.addAction(
                UIAlertAction(title: Constants.googleMaps, style: .default) { action in
                    Constants.sammysCoordinates.openInGoogleMaps()
                })
        }
        // Add Waze action if user has downloaded.
        if URL.canOpen(Constants.wazeBaseURL) {
            navigationAlertController.addAction(
                UIAlertAction(title: Constants.wazeBaseURL, style: .default) { action in
                    Constants.sammysCoordinates.navigateInWaze()
                })
        }
        // Add cancel action.
        navigationAlertController.addAction(
            UIAlertAction(title: "Cancel", style: .cancel) { action in
            navigationAlertController.dismiss(animated: true, completion: nil)
            })
        present(navigationAlertController, animated: true, completion: nil)
    }
    
    func cellViewModel(at row: Int) -> CollectionViewCellViewModel? {
        guard !cellViewModels.isEmpty && row < cellViewModels.count else { return nil }
        return cellViewModels[row]
    }
}

extension ConfirmationViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cellViewModel = cellViewModel(at: indexPath.row)
            else { fatalError() }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellViewModel.identifier, for: indexPath)
        cellViewModel.commands[.configuration]?.perform(parameters: CommandParameters(cell: cell))
        return cell
    }
}

extension ConfirmationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cellViewModel(at: indexPath.row)?.commands[.selection]?.perform(parameters: CommandParameters(viewController: self))
    }
}

private extension CLLocationCoordinate2D {
    func openInMaps() {
        let placemark = MKPlacemark(coordinate: self, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = ConfirmationViewController.Constants.sammys
        mapItem.openInMaps(launchOptions: nil)
    }
    
    func navigateInWaze() {
        guard URL.canOpen(ConfirmationViewController.Constants.wazeBaseURL) else { return }
        URL.open("\(ConfirmationViewController.Constants.wazeBaseURL)?ll=\(latitude),\(longitude)&navigate=yes")
    }
    
    func openInGoogleMaps() {
        guard URL.canOpen(ConfirmationViewController.Constants.googleMapsBaseURL) else { return }
        URL.open("\(ConfirmationViewController.Constants.googleMapsBaseURL)?q=\(latitude),\(longitude)")
    }
}
