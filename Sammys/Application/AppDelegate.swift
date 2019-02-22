//
//  AppDelegate.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import Firebase

#if DEBUG
let environment = AppEnvironment.development
#else
let environment = AppEnvironment.production
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let window = UIWindow(frame: UIScreen.main.bounds)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let tabViewController = UITabBarController()
        let homeViewController = HomeViewController()
        tabViewController.viewControllers = [homeViewController]
        
        window.rootViewController = UINavigationController(rootViewController: tabViewController)
        window.makeKeyAndVisible()
        
        // Configure Firebase
        FirebaseApp.configure()
        
        return true
    }
}
