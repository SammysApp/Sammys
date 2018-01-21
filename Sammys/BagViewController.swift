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
    lazy var sortedItemsKeys = Array(items.keys).sorted { $0.rawValue < $1.rawValue }
    
    var subtotalPrice: Double {
        var totalPrice = 0.0
        for (_, foods) in items {
            foods.forEach { totalPrice += $0.price }
        }
        return totalPrice.rounded(toPlaces: 2)
    }
    
    var taxPrice: Double {
        return (subtotalPrice * (6.88/100)).rounded(toPlaces: 2)
    }
    
    var finalPrice: Double {
        return (subtotalPrice + taxPrice).rounded(toPlaces: 2)
    }

    // MARK: IBOutlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var subtotalLabel: UILabel!
    @IBOutlet var taxLabel: UILabel!
    @IBOutlet var purchaseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        purchaseButton.layer.cornerRadius = 20
        updateUI()
    }
    
    /**
     Updates to UI based on external factors
     */
    func updateUI() {
        subtotalLabel.text = subtotalPrice.priceString
        taxLabel.text = taxPrice.priceString
        purchaseButton.setTitle(finalPrice.priceString, for: .normal)
    }
    
    @IBAction func purchase(_ sender: UIButton) {
        if user == nil {
            present(LoginViewController.storyboardInstance(), animated: true, completion: nil)
        } else {
            if let id = user!.customerID {
                PayAPIClient.charge(id, amount: finalPrice.toCents())
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
        let key = sortedItemsKeys[section]
        return items[key]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let key = sortedItemsKeys[indexPath.section]
        let food = items[key]![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ItemTableViewCell
        
        switch food {
        case let salad as Salad:
            cell.titleLabel.text = "\(salad.size!.name) Salad"
        default: break
        }
        
        cell.descriptionLabel.text = food.itemDescription
        cell.priceLabel.text = food.price.priceString
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
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

extension Double {
    var priceString: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        return numberFormatter.string(from: NSNumber(value: self))!
    }
    
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded()/divisor
    }
}
