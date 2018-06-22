//
//  AppDelegate.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import Firebase
import Stripe
import FBSDKCoreKit

#if DEBUG
let environment = AppEnvironment.debug
#elseif FAMILY
let environment = AppEnvironment.family
#else
let environment = AppEnvironment.release
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    // The root window of the app.
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        print("Running in \(environment) mode!")
        
        // Configure Firebase.
        FirebaseApp.configure()
        
        // Configure Facebook SDK.
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Set Stripe publishable key to be able to create tokens.
        STPPaymentConfiguration.shared().publishableKey = environment.isLive ? apiKey(for: .stripePublishableLive) : apiKey(for: .stripePublishableTest)
        
        // Start listening for changes to user.
        UserAPIClient.startUserStateDidChangeListener()
        
        // Start listening for changes to favorites.
        UserAPIClient.startFavoritesValueChangeObserver()
        
        // Set as user API observer.
        UserDataStore.shared.setAsUserAPIObsever()
        
        // Configure navigation bar appearance.
        UINavigationBar.appearance().barTintColor = #colorLiteral(red: 0.3333333333, green: 0.3019607843, blue: 0.2745098039, alpha: 1)
        UINavigationBar.appearance().tintColor = #colorLiteral(red: 0.9800000191, green: 0.9800000191, blue: 0.9800000191, alpha: 1)
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: #colorLiteral(red: 0.9800000191, green: 0.9800000191, blue: 0.9800000191, alpha: 1)]
        UINavigationBar.appearance().isTranslucent = false
        
        // Show status bar after it being initially hidden in Info.plist.
        UIApplication.shared.isStatusBarHidden = false
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
}
