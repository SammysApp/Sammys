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
let appEnvironment = AppEnvironment.development
#else
let appEnvironment = AppEnvironment.production
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let window = UIWindow(frame: UIScreen.main.bounds)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureWindow()
        FirebaseApp.configure()
        return true
    }
    
    private func configureWindow() {
        window.rootViewController = makeTabBarController()
        window.makeKeyAndVisible()
    }
    
    private func makeTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        let homeViewController = HomeViewController()
        homeViewController.tabBarItem = .init(tabBarSystemItem: .topRated, tag: 0)
        let bagViewController = BagViewController()
        bagViewController.tabBarItem = .init(tabBarSystemItem: .topRated, tag: 1)
        tabBarController.viewControllers = [homeViewController, bagViewController]
            .map { UINavigationController(rootViewController: $0) }
        return tabBarController
    }
}
