//
//  UserViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/11/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import Stripe

class UserViewController: UIViewController, Storyboardable {
    typealias ViewController = UserViewController
    
    var user: User? {
        return UserDataStore.shared.user
    }
    
    // MARK: - IBOutlets & View Properties
    @IBOutlet var tableView: UITableView!
    
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return info?.count ?? 0
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            let key = Array(info!.keys)[indexPath.row]
            cell.textLabel?.text = key
            cell.detailTextLabel?.text = info![key]!
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell", for: indexPath)
            cell.textLabel?.text = "Add Credit Card"
            return cell
        default: return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            tableView.deselectRow(at: indexPath, animated: true)
//            let theme = STPTheme()
//            theme.accentColor = UIColor(named: "Mocha")
            let vc = STPAddCardViewController()
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension UserViewController: STPAddCardViewControllerDelegate {
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        PayAPIClient.createNewCustomer(with: token.tokenId)
        navigationController?.popToRootViewController(animated: true)
    }
}
