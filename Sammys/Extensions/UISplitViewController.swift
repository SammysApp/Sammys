//
//  UISplitViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 6/27/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

extension UISplitViewController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        // Set the style to the style of the first child controller if it's available.
        return childViewControllers.first?.preferredStatusBarStyle ?? .default
    }
}
