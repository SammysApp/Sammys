//
//  HomeViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/21/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit
import TinyConstraints

class HomeViewController: UIViewController {
    private let viewModel = HomeViewModel()
    
    private let tableView = UITableView()
    
    private lazy var tableViewDataSource = {
        TableViewSectionsUITableViewDataSource(dataSource: self)
    }()
    private lazy var tableViewDelegate = {
        TableViewSectionsUITableViewDelegate(dataSource: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        [tableView].forEach { self.view.addSubview($0) }
        
        tableView.register(ImageTableViewCell.self, forCellReuseIdentifier: HomeCellIdentifier.imageCell.rawValue)
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
        tableView.edgesToSuperview()
    }
}

extension HomeViewController: TableViewSectionsDataSource {
    func tableViewSections(for tableView: UITableView) -> [TableViewSection] {
        return viewModel.tableViewSections
    }
}
