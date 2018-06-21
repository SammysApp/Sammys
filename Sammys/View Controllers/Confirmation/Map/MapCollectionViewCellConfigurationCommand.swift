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
        static let latitudinalMeters = 125.0
        static let longitudinalMeters = 125.0
    }
    
    func perform(parameters: CommandParameters) {
        guard let cell = parameters.cell as? MapCollectionViewCell else { return }
        // Configure cell UI.
        ConfirmationViewController.configureUI(for: cell)
        cell.contentView.backgroundColor = .clear
        
        // Configure map details.
        let region =  MKCoordinateRegionMakeWithDistance(ConfirmationViewController.Constants.sammysCoordinates, Constants.latitudinalMeters, Constants.longitudinalMeters)
        cell.mapView.region = region
    }
}
