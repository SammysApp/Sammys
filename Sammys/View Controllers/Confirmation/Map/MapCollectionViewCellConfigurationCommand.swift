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
        static let CornerRadius: CGFloat = 20
        static let BorderWidth: CGFloat = 1
        static let ShadowOpacity: Float = 0.2
        static let LocationLatitude = 40.902340
        static let LocationLongitude = -74.004410
        static let LatitudinalMeters = 125.0
        static let LongitudinalMeters = 125.0
    }
    
    func perform(parameters: CommandParameters) {
        guard let cell = parameters.cell as? MapCollectionViewCell else { return }
        // Configure cell UI.
        cell.contentView.layer.masksToBounds = true
        cell.contentView.backgroundColor = .clear
        cell.contentView.layer.cornerRadius = Constants.CornerRadius
        cell.contentView.layer.borderWidth = Constants.BorderWidth
        cell.contentView.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.masksToBounds = false
        cell.add(UIView.Shadow(path: UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath, opacity: Constants.ShadowOpacity))
        
        // Configure map details.
        let center = CLLocationCoordinate2D(latitude: Constants.LocationLatitude, longitude: Constants.LocationLongitude)
        let region =  MKCoordinateRegionMakeWithDistance(center, Constants.LatitudinalMeters, Constants.LongitudinalMeters)
        cell.mapView.region = region
    }
}
