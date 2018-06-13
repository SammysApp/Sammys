//
//  AppDelegate.swift
//  Sammys Kitchen
//
//  Created by Natanel Niazoff on 5/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import Firebase
import SwiftySound

var currentDate = Date()

#if DEBUG
let environment = AppEnvironment.debug
#else
let environment = AppEnvironment.release
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var silenceSound: Sound?
    
    private struct Constants {
        static let silenceFileName = "Silence"
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Configure Firebase.
        FirebaseApp.configure()
        
        // Configure navigation bar appearance.
        UINavigationBar.appearance().barTintColor = #colorLiteral(red: 0.3333333333, green: 0.3019607843, blue: 0.2745098039, alpha: 1)
        UINavigationBar.appearance().tintColor = #colorLiteral(red: 0.9800000191, green: 0.9800000191, blue: 0.9800000191, alpha: 1)
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: #colorLiteral(red: 0.9800000191, green: 0.9800000191, blue: 0.9800000191, alpha: 1)]
        UINavigationBar.appearance().isTranslucent = false
        
        // Configure status bar style.
        UIApplication.shared.statusBarStyle = .lightContent
        
        // Start observing for today's orders and set notification for day change.
        startOrdersValueChangeObserver(for: currentDate)
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.dayDidChange), name: .NSCalendarDayChanged, object: nil)
        
        // Setup silence sound to be used throughout app.
        if let url = Bundle.main.url(forResource: Constants.silenceFileName, withExtension: FileExtension.wav.rawValue),
            let sound = Sound(url: url) {
            silenceSound = sound
        }
        
        // Set to play silent sound every minute to keep any speaker on for alerts.
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
            silenceSound?.play()
        }.fire()
        
        return true
    }
    
    /// Starts observing for orders for the current date.
    func startOrdersValueChangeObserver(for date: Date) {
        OrdersAPIClient.startOrdersValueChangeObserver(for: date)
    }
    
    func removeAllOrdersObservers(for date: Date) {
        OrdersAPIClient.removeAllOrdersObservers(for: date)
    }
    
    @objc
    func dayDidChange() {
        removeAllOrdersObservers(for: currentDate)
        currentDate = Date()
        startOrdersValueChangeObserver(for: currentDate)
    }
}
