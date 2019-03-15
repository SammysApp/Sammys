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
    
    private struct Constants {
        static let homeTabBarItemTitle = "Home"
    }
    
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
        tabBarController.tabBar.tintColor = #colorLiteral(red: 0.3294117647, green: 0.1921568627, blue: 0.09411764706, alpha: 1)
        let homeViewController = HomeViewController()
        homeViewController.tabBarItem = .init(title: Constants.homeTabBarItemTitle, image: #imageLiteral(resourceName: "Home"), tag: 0)
        let bagViewController = OutstandingOrderViewController()
        bagViewController.tabBarItem = .init(tabBarSystemItem: .topRated, tag: 1)
        tabBarController.viewControllers = [homeViewController, bagViewController]
            .map { UINavigationController(rootViewController: $0) }
        return tabBarController
    }
}
