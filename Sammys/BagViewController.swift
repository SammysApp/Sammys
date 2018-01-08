//
//  BagViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/8/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class BagViewController: UIViewController, Storyboardable {
    typealias ViewController = BagViewController

    // MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension BagViewController: UITableViewDataSource, UITableViewDelegate {
    
}
