//
//  BagViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/8/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import Stripe

class BagViewController: UIViewController, Storyboardable {
    typealias ViewController = BagViewController
    
    let data = BagDataStore.shared
    var items: BagDataStore.Items {
        return data.items
    }
    var user: User? {
        return UserDataStore.shared.user
    }

    // MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var purchaseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        purchaseButton.layer.cornerRadius = 20
        updateUI()
    }
    
    func updateUI() {
        if let totalPrice = data.itemsTotalPrice {
            purchaseButton.isHidden = false
            purchaseButton.setTitle("$\(totalPrice)", for: .normal)
        } else {
            purchaseButton.isHidden = true
        }
    }
    
    @IBAction func purchase(_ sender: UIButton) {
        guard let amount = data.itemsTotalPrice else {
            return
        }
        if user == nil {
            present(LoginViewController.storyboardInstance(), animated: true, completion: nil)
        } else {
            if let id = user!.customerID {
                PayAPIClient.charge(id, amount: amount.toCents())
            } else {
                let vc = STPAddCardViewController()
                vc.delegate = self
                let nvc = UINavigationController(rootViewController: vc)
                present(nvc, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func clearBag(_ sender: UIButton) {
        data.clear()
        tableView.reloadData()
        updateUI()
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension BagViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[Array(items.keys)[section]]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let food = items[Array(items.keys)[indexPath.section]]![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        if let salad = food as? Salad {
            cell.textLabel?.text = salad.size?.name
        }
        return cell
    }
}

extension BagViewController: STPAddCardViewControllerDelegate {
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        PayAPIClient.chargeNewUser(with: token.tokenId, amount: 1000)
        dismiss(animated: true, completion: nil)
    }
}
