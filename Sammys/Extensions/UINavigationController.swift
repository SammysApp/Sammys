//
//  UINavigationController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/22/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        // Set the style to the style of the top view controller if it's available.
        return topViewController?.preferredStatusBarStyle ?? .default
    }
}
