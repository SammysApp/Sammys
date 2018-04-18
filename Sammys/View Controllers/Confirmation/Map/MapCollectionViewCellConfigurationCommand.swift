//
//  MapCollectionViewCellConfigurationCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/13/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

struct MapCollectionViewCellConfigurationCommand: CollectionViewCellCommand {
    private struct Constants {
        static let cornerRadius: CGFloat = 20
        static let borderWidth: CGFloat = 1
        static let shadowOpacity: Float = 0.2
        static let latitudinalMeters = 125.0
        static let longitudinalMeters = 125.0
    }
    
    func perform(parameters: CommandParameters) {
        guard let cell = parameters.cell as? MapCollectionViewCell else { return }
        // Configure cell UI.
        cell.contentView.layer.masksToBounds = true
        cell.contentView.backgroundColor = .clear
        cell.contentView.layer.cornerRadius = Constants.cornerRadius
        cell.contentView.layer.borderWidth = Constants.borderWidth
        cell.contentView.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.masksToBounds = false
        cell.add(UIView.Shadow(path: UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath, opacity: Constants.shadowOpacity))
        
        // Configure map details.
        let region =  MKCoordinateRegionMakeWithDistance(ConfirmationViewController.Constants.sammysCoordinates, Constants.latitudinalMeters, Constants.longitudinalMeters)
        cell.mapView.region = region
    }
}
