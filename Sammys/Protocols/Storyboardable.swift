//
//  Storyboardable.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/26/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

/// A `UIViewController` that has a matching storyboard file with the same name.
protocol Storyboardable where Self: UIViewController {}

extension Storyboardable {
	/// Returns a `UIViewController` instance with the initial view controller of the matching storyboard file in the given bundle.
	static func storyboardInstance(bundle: Bundle = Bundle.main) -> Self {
        let className = String(describing: Self.self)
        let storyboard = UIStoryboard(name: className, bundle: bundle)
		if let initialViewController = storyboard.instantiateInitialViewController() as? Self {
			return initialViewController
		} else { fatalError("Could not instantiate a \(className) instance from the storyboard.") }
    }
}
