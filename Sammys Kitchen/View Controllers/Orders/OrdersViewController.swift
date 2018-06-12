//
//  OrdersViewController.swift
//  Sammys Kitchen
//
//  Created by Natanel Niazoff on 5/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import SwiftySound
import AVFoundation

class OrdersViewController: UITableViewController {
    let viewModel = OrdersViewModel()
    var alertSound: Sound?
    var silenceSound: Sound?
    
    static let storyboardID = "ordersViewController"
    
    private struct Constants {
        static let alertFileName = "Alert"
        static let silenceFileName = "Silence"
        static let wavFileExtension = "wav"
        static let alertNumberOfLoops = 2
        static let alertMessage = "there's a new order"
    }
    
    private enum SegueIdentifier: String {
        case showFood
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        tableView.separatorInset.left = 30
        tableView.separatorColor = #colorLiteral(red: 0.8901960784, green: 0.862745098, blue: 0.8352941176, alpha: 1)
        splitViewController?.view.backgroundColor = #colorLiteral(red: 0.3960784314, green: 0.3568627451, blue: 0.3215686275, alpha: 1)
        
        if let url = Bundle.main.url(forResource: Constants.alertFileName, withExtension: Constants.wavFileExtension),
            let sound = Sound(url: url) {
            alertSound = sound
        }
        
        if let url = Bundle.main.url(forResource: Constants.silenceFileName, withExtension: Constants.wavFileExtension),
            let sound = Sound(url: url) {
            silenceSound = sound
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController?.isCollapsed ?? false
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.handleViewDidAppear()
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        viewModel.handleViewDidDisappear()
        super.viewDidDisappear(animated)
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        switch viewModel.viewKey {
        case .orders:
            guard let ordersViewController = storyboard?.instantiateViewController(withIdentifier: OrdersViewController.storyboardID) as? OrdersViewController else { return }
            ordersViewController.viewModel.viewKey = .foods
            ordersViewController.viewModel.orderFoods = viewModel.foods(for: indexPath)
            ordersViewController.title = viewModel.orderTitle(for: indexPath)
            navigationController?.pushViewController(ordersViewController, animated: true)
        case .foods:
            performSegue(withIdentifier: SegueIdentifier.showFood.rawValue, sender: nil)
        }
    }
    
    func playAlertSound() {
        silenceSound?.play() { completed in
            guard completed else { return }
            self.alertSound?.play(numberOfLoops: Constants.alertNumberOfLoops - 1) {
                guard $0 else { return }
                self.speakMessage()
            }
        }
    }
    
    func speakMessage() {
        let message = Constants.alertMessage
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifierString = segue.identifier,
            let identifier = SegueIdentifier(rawValue: identifierString) else { return }
        switch identifier {
        case .showFood:
            guard let orderViewController = (segue.destination as? UINavigationController)?.topViewController as? FoodViewController,
                let indexPath = tableView.indexPathForSelectedRow,
                let food = viewModel.food(for: indexPath) else { return }
            orderViewController.food = food
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(inSection: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellViewModel = viewModel.cellViewModel(for: indexPath) else { fatalError() }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.identifier, for: indexPath)
        cellViewModel.commands[.configuration]?.perform(cell: cell)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cellViewModel = viewModel.cellViewModel(for: indexPath) else { fatalError() }
        return cellViewModel.height
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cellViewModel = viewModel.cellViewModel(for: indexPath),
            let cell = tableView.cellForRow(at: indexPath) else { fatalError() }
        cellViewModel.commands[.selection]?.perform(cell: cell)
        didSelectRow(at: indexPath)
    }
}

extension OrdersViewController: OrdersViewModelDelegate {
    func needsUIUpdate() {
        tableView.reloadData()
    }
    
    func didGetNewOrder() {
        playAlertSound()
    }
}
