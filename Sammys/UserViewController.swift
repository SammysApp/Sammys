//
//  UserViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/11/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class UserViewController: UIViewController, Storyboardable {
    typealias ViewController = UserViewController
    
    var user: User? {
        return UserDataStore.shared.user
    }
    
    // MARK: - IBOutlets & View Properties
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var info: [String : String]? {
        return user != nil ? ["Name": user!.name, "Email": user!.email] : nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if user == nil {
            present(LoginViewController.storyboardInstance(), animated: true, completion: nil)
        } else {
            tableView.reloadData()
        }
    }

    @IBAction func done(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension UserViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return info?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let key = Array(info!.keys)[indexPath.row]
        cell.textLabel?.text = key
        cell.detailTextLabel?.text = info![key]!
        return cell
    }
}
