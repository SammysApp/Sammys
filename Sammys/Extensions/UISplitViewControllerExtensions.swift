//
//  UISplitViewControllerExtensions.swift
//  Sammys
//
//  Created by Natanel Niazoff on 6/27/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

extension UISplitViewController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.children.first?.preferredStatusBarStyle ?? .default
    }
}
