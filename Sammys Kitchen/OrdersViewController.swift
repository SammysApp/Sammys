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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        tableView.separatorInset.left = 30
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController?.isCollapsed ?? false
        super.viewWillAppear(animated)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
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

