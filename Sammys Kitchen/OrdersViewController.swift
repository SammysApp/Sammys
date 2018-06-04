//
//  OrdersViewController.swift
//  Sammys Kitchen
//
//  Created by Natanel Niazoff on 5/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class OrdersViewController: UITableViewController {
    let viewModel = OrdersViewModel()
    
    private enum SegueIdentifier: String {
        case showOrder
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        tableView.separatorInset.left = 30
        tableView.separatorColor = #colorLiteral(red: 0.8901960784, green: 0.862745098, blue: 0.8352941176, alpha: 1)
        splitViewController?.view.backgroundColor = #colorLiteral(red: 0.3960784314, green: 0.3568627451, blue: 0.3215686275, alpha: 1)
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController?.isCollapsed ?? false
        super.viewWillAppear(animated)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifierString = segue.identifier,
            let identifier = SegueIdentifier(rawValue: identifierString) else { return }
        switch identifier {
        case .showOrder:
            guard let orderViewController = (segue.destination as? UINavigationController)?.topViewController as? OrderViewController,
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
    }
}

extension OrdersViewController: OrdersViewModelDelegate {
    func needsUIUpdate() {
        tableView.reloadData()
    }
}

