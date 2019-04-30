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
import TinyConstraints

#if DEBUG
let appEnvironment = AppEnvironment.development
#else
let appEnvironment = AppEnvironment.production
#endif

let homeViewControllerTabBarControllerIndex = 0
let favoritesViewControllerTabBarControllerIndex = 1
let outstandingOrderViewControllerTabBarControllerIndex = 2

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let window = UIWindow(frame: UIScreen.main.bounds)
    
    private struct Constants {
        static let squareApplicationID = "sq0idp-uGmV90aWUn6nFGhNYL6ICw"
        
        static let tabBarControllerTabBarTintColor = #colorLiteral(red: 0.3294117647, green: 0.1921568627, blue: 0.09411764706, alpha: 1)
        
        static let homeViewControllerTabBarItemTitle = "Home"
        static let homeViewControllerTabBarItemImage = #imageLiteral(resourceName: "TabBar.Home")
        
        static let favoritesViewControllerTabBarItemTitle = "Favorites"
        static let favoritesViewControllerTabBarItemImage = #imageLiteral(resourceName: "TabBar.Heart")
        
        static let outstandingOrderViewControllerTitle = "Bag"
        static let outstandingOrderViewControllerTabBarItemImage = #imageLiteral(resourceName: "TabBar.Bag")
        static let outstandingOrderViewControllerTabBarItemBadgeColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
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
        homeViewController.tabBarItem = .init(
            title: Constants.homeViewControllerTabBarItemTitle,
            image: Constants.homeViewControllerTabBarItemImage,
            tag: homeViewControllerTabBarControllerIndex
        )
        
        let favoritesViewController = UIViewController()
        favoritesViewController.tabBarItem = .init(
            title: Constants.favoritesViewControllerTabBarItemTitle,
            image: Constants.favoritesViewControllerTabBarItemImage,
            tag: favoritesViewControllerTabBarControllerIndex
        )
        
        let outstandingOrderViewController = OutstandingOrderViewController()
        outstandingOrderViewController.title = Constants.outstandingOrderViewControllerTitle
        outstandingOrderViewController.tabBarItem = .init(
            title: Constants.outstandingOrderViewControllerTitle,
            image: Constants.outstandingOrderViewControllerTabBarItemImage,
            tag: outstandingOrderViewControllerTabBarControllerIndex
        )
        outstandingOrderViewController.tabBarItem.badgeColor = Constants.outstandingOrderViewControllerTabBarItemBadgeColor
        
        tabBarController.viewControllers = [homeViewController, favoritesViewController, outstandingOrderViewController]
            .map { UINavigationController(rootViewController: $0) }
        return tabBarController
    }
}
