//
//  Storyboardable.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/26/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol Storyboardable {
    associatedtype ViewController: UIViewController
}

extension Storyboardable where Self: UIViewController {
    static func storyboardInstance() -> UIViewController {
        let className = String(describing: ViewController.self)
        let storyboard = UIStoryboard(name: className, bundle: nil)
        return storyboard.instantiateInitialViewController()!
    }
}
