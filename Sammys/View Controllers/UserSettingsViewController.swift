//
//  UserSettingsViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/6/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class UserSettingsViewController: UIViewController {
    let viewModel = UserSettingsViewModel()
    
    // MARK: - IBOutlets
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

extension UserSettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(inSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = viewModel.cellViewModel(for: indexPath)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.identifier) else { fatalError() }
        cellViewModel.commands[.configuration]?.perform(cell: cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellViewModel(for: indexPath).height
    }
}

extension UserSettingsViewController: Storyboardable {
    typealias ViewController = UserSettingsViewController
}
