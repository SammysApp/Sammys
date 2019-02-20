//
//  Storyboardable.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/26/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

/// A `UIViewController` that's able to be instantiated by a storyboard file
/// with a matching name
protocol Storyboardable where Self: UIViewController {}

extension Storyboardable {
    /// Returns a `UIViewController` instance of the same type with the initial view
    /// controller of the matching storyboard file in the given bundle.
	static func storyboardInstance(bundle: Bundle = Bundle.main) -> Self {
        let typeName = String(describing: Self.self)
        let storyboard = UIStoryboard(name: typeName, bundle: bundle)
		if let initialViewController =
            storyboard.instantiateInitialViewController() as? Self {
			return initialViewController
		} else {
            fatalError("Could not instantiate a \(typeName) instance from the storyboard.")
        }
    }
}
