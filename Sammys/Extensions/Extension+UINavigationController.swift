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
        return topViewController?.preferredStatusBarStyle ?? .default
    }
}
