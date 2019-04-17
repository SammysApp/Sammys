//
//  AppDelegate.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import Firebase
import SquareInAppPaymentsSDK

#if DEBUG
let appEnvironment = AppEnvironment.development
#else
let appEnvironment = AppEnvironment.production
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let window = UIWindow(frame: UIScreen.main.bounds)
    
    private struct Constants {
        static let squareApplicationID = "sq0idp-uGmV90aWUn6nFGhNYL6ICw"
        
        static let tabBarControllerTabBarTintColor = #colorLiteral(red: 0.3294117647, green: 0.1921568627, blue: 0.09411764706, alpha: 1)
        
        static let homeTabBarItemTitle = "Home"
        static let favoritesTabBarItemTitle = "Favorites"
        static let outstandingOrderTitle = "Bag"
        
        static let homeTabBarItemImage = #imageLiteral(resourceName: "TabBar.Home")
        static let favoritesTabBarItemImage = #imageLiteral(resourceName: "TabBar.Heart")
        static let outstandingOrderTabBarItemImage = #imageLiteral(resourceName: "TabBar.Bag")
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        SQIPInAppPaymentsSDK.squareApplicationID = Constants.squareApplicationID
        
        configureWindow()
        window.makeKeyAndVisible()
        
        return true
    }
    
    private func configureWindow() {
        window.rootViewController = makeTabBarController()
    }
    
    private func makeTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        tabBarController.tabBar.tintColor = Constants.tabBarControllerTabBarTintColor
        
        let homeViewController = HomeViewController()
        homeViewController.tabBarItem = .init(title: Constants.homeTabBarItemTitle, image: Constants.homeTabBarItemImage , tag: 0)
        
        let favoritesViewController = UIViewController()
        favoritesViewController.tabBarItem = .init(title: Constants.favoritesTabBarItemTitle, image: Constants.favoritesTabBarItemImage, tag: 1)
        
        let outstandingOrderViewController = OutstandingOrderViewController()
        outstandingOrderViewController.title = Constants.outstandingOrderTitle
        outstandingOrderViewController.tabBarItem = .init(title: Constants.outstandingOrderTitle, image: Constants.outstandingOrderTabBarItemImage, tag: 2)
        
        tabBarController.viewControllers = [homeViewController, favoritesViewController, outstandingOrderViewController]
            .map { UINavigationController(rootViewController: $0) }
        return tabBarController
    }
}
