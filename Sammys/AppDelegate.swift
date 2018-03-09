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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    // The root window of the app.
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Configure Firebase.
        FirebaseApp.configure()
        
        // Set Stripe publishable key to be able to create tokens.
        STPPaymentConfiguration.shared().publishableKey = "pk_test_wzWkBv3TCpgT1Yc8DzAU09zV"
        
        // Start listening for changes to user.
        UserAPIClient.startUserStateDidChangeListener()
        
        // Set as user API observer.
        UserDataStore.shared.setAsUserAPIObsever()
        
        return true
    }
}

