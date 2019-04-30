//
//  AppDelegate.swift
//  Kitchen
//
//  Created by Natanel Niazoff on 4/17/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit
import AVFoundation
import Starscream
import TinyConstraints

#if DEBUG
let appEnvironment = AppEnvironment.development
#else
let appEnvironment = AppEnvironment.production
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let window = UIWindow(frame: UIScreen.main.bounds)
    
    private(set) lazy var purchasedOrdersViewController = PurchasedOrdersViewController()
    
    let socketID = UUID()
    private(set) lazy var socket = WebSocket(url: makeSocketURL())
    
    private let bellSoundPlayer: AVAudioPlayer
    private let synthesizer = AVSpeechSynthesizer()
    private var currentPurchasedOrderUtterance: AVSpeechUtterance?
    
    private lazy var dataDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    private struct Constants {
        static let bellSoundFileName = "Bell"
        static let bellSoundFileExtension = "wav"
    }
    
    override init() {
        guard let bellSoundURL = Bundle.main.url(
            forResource: Constants.bellSoundFileName,
            withExtension: Constants.bellSoundFileExtension
        ) else { preconditionFailure() }
        do { self.bellSoundPlayer = try AVAudioPlayer(contentsOf: bellSoundURL) }
        catch { preconditionFailure(error.localizedDescription) }
        
        super.init()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureSocket()
        socket.connect()
        
        configureBellSoundPlayer()
        
        configureWindow()
        window.makeKeyAndVisible()
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        socket.disconnect()
    }
    
    // MARK: - Setup Methods
    private func configureWindow() {
        window.rootViewController = makeSplitViewController()
    }
    
    private func configureBellSoundPlayer() {
        bellSoundPlayer.delegate = self
    }
    
    private func configureSocket() {
        socket.onData = didReceiveSocketData
    }
    
    // MARK: - Factory Methods
    private func makeSplitViewController() -> UISplitViewController {
        let splitViewController = UISplitViewController()
        splitViewController.viewControllers = [
            UINavigationController(rootViewController: purchasedOrdersViewController),
            UINavigationController(rootViewController: CategorizedItemsViewController())
        ]
        return splitViewController
    }
    
    private func makeSocketURL() -> URL {
        var components = URLComponents()
        components.scheme = "ws"
        components.host = LocalConstants.DevelopmentAPIServer.host
        components.port = LocalConstants.DevelopmentAPIServer.port
        components.path = "/v1/sessions/\(socketID.uuidString)"
        guard let url = components.url else { preconditionFailure() }
        return url
    }
    
    private func makePurchasedOrderUtterance(purchasedOrder: PurchasedOrder) -> AVSpeechUtterance {
        var string = "New order"
        if let user = purchasedOrder.user { string += " for \(user.firstName)" }
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        return utterance
    }
    
    private func didReceiveSocketData(_ data: Data) {
        if let purchasedOrder = try? dataDecoder.decode(PurchasedOrder.self, from: data) {
            currentPurchasedOrderUtterance = makePurchasedOrderUtterance(purchasedOrder: purchasedOrder)
            if !bellSoundPlayer.isPlaying { bellSoundPlayer.play() }
            purchasedOrdersViewController.viewModel.beginDownloads()
        }
    }
}

extension AppDelegate: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if player == bellSoundPlayer, let utterance = currentPurchasedOrderUtterance {
            synthesizer.speak(utterance)
        }
    }
}
