//
//  ActiveOrderMapTableViewCellConfigurationCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/13/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

struct ActiveOrderMapTableViewCellConfigurationCommand: TableViewCellCommand {
	private struct Constants {
        static let latitudinalMeters = 125.0
        static let longitudinalMeters = 125.0
    }
    
    func perform(parameters: TableViewCellCommandParameters) {
        guard let cell = parameters.cell as? ActiveOrderMapTableViewCell else { return }
		do {
			let appData = try AppData.get()
			cell.mapView.region = MKCoordinateRegionMakeWithDistance(
				CLLocationCoordinate2D(latitude: appData.sammys.latitude, longitude: appData.sammys.longitude),
				Constants.latitudinalMeters,
				Constants.longitudinalMeters
			)
		} catch { print(error) }
    }
}
