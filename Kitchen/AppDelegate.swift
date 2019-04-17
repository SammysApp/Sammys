//
//  AppDelegate.swift
//  Kitchen
//
//  Created by Natanel Niazoff on 4/17/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

#if DEBUG
let appEnvironment = AppEnvironment.development
#else
let appEnvironment = AppEnvironment.production
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let window = UIWindow(frame: UIScreen.main.bounds)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureWindow()
        window.makeKeyAndVisible()
        
        return true
    }
    
    private func configureWindow() {
        window.rootViewController = makeSplitViewController()
    }
    
    private func makeSplitViewController() -> UISplitViewController {
        let splitViewController = UISplitViewController()
        splitViewController.viewControllers = [
            UINavigationController(rootViewController: PurchasedOrderViewController()),
            UINavigationController(rootViewController: UIViewController())
        ]
        return splitViewController
    }
}

