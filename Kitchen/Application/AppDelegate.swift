//
//  AppDelegate.swift
//  Kitchen
//
//  Created by Natanel Niazoff on 4/17/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit
import Starscream

#if DEBUG
let appEnvironment = AppEnvironment.development
#else
let appEnvironment = AppEnvironment.production
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let window = UIWindow(frame: UIScreen.main.bounds)
    
    let socketID = UUID()
    private(set) lazy var socket = WebSocket(url: makeSocketURL())
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureSocket()
        socket.connect()
        
        configureWindow()
        window.makeKeyAndVisible()
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        socket.disconnect()
    }
    
    private func makeSocketURL() -> URL {
        var components = URLComponents()
        components.scheme = "ws"
        components.host = LocalConstants.DevelopmentAPIServer.host
        components.port = LocalConstants.DevelopmentAPIServer.port
        components.path = "/v1/orderSessions/\(socketID.uuidString)"
        guard let url = components.url else { preconditionFailure() }
        return url
    }
    
    private func configureSocket() {
        socket.onData = didReceiveSocketData
    }
    
    private func configureWindow() {
        window.rootViewController = makeSplitViewController()
    }
    
    private func makeSplitViewController() -> UISplitViewController {
        let splitViewController = UISplitViewController()
        splitViewController.viewControllers = [
            UINavigationController(rootViewController: PurchasedOrdersViewController()),
            UINavigationController(rootViewController: CategorizedItemsViewController())
        ]
        return splitViewController
    }
    
    private func didReceiveSocketData(_ data: Data) {
        
    }
}
