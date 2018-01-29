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
    let viewModel = BagViewModel()

    // MARK: IBOutlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var subtotalLabel: UILabel!
    @IBOutlet var taxLabel: UILabel!
    @IBOutlet var purchaseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 100
        purchaseButton.layer.cornerRadius = 20
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    /**
     Updates UI based on external factors
     */
    func updateUI() {
        subtotalLabel.text = viewModel.subtotalPrice.priceString
        taxLabel.text = viewModel.taxPrice.priceString
        purchaseButton.setTitle(viewModel.finalPrice.priceString, for: .normal)
    }
    
    func editItem(for food: Food) {
        let itemsViewController = ItemsViewController.storyboardInstance() as! ItemsViewController
        itemsViewController.salad = food as! Salad
        itemsViewController.isEditingFood = true
        itemsViewController.finishEditing = {
            self.tableView.reloadData()
            self.updateUI()
            self.viewModel.finishEditing()
        }
        navigationController?.pushViewController(itemsViewController, animated: true)
    }
    
    func delete(_ food: Food) {
        if let indexPath = viewModel.indexPath(for: food) {
            var indexPathsToDelete = [indexPath]
            let nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
            if let nextKey = viewModel.item(for: nextIndexPath)?.key, case .quantity = nextKey {
                indexPathsToDelete.append(nextIndexPath)
            }
            viewModel.remove(food) { removedSection in
                if removedSection {
                    self.tableView.deleteSections([indexPath.section], with: .fade)
                } else {
                    self.tableView.deleteRows(at: indexPathsToDelete, with: .automatic)
                }
                self.updateUI()
            }
        }
    }

    
    @IBAction func purchase(_ sender: UIButton) {
//        if user == nil {
//            present(LoginViewController.storyboardInstance(), animated: true, completion: nil)
//        } else {
//            if let id = user!.customerID {
//                PayAPIClient.charge(id, amount: finalPrice.toCents())
//            } else {
//                let vc = STPAddCardViewController()
//                vc.delegate = self
//                let nvc = UINavigationController(rootViewController: vc)
//                present(nvc, animated: true, completion: nil)
//            }
//        }
    }
    
    @IBAction func clearBag(_ sender: UIButton) {
        viewModel.clearBag()
        tableView.reloadData()
        updateUI()
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension BagViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.item(for: indexPath)!
        switch item.key {
        case .food:
            let foodItem = item as! FoodBagItem
            let food = foodItem.food
            let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ItemTableViewCell
            
            switch food {
            case let salad as Salad:
                cell.titleLabel.text = "\(salad.size!.name) Salad"
            default: break
            }
            
            cell.descriptionLabel.text = food.itemDescription
            cell.priceLabel.text = food.price.priceString
            
            cell.edit = { cell in
                self.editItem(for: food)
            }
            
            return cell
        case .quantity:
            let quantityItem = item as! QuantityBagItem
            var food = quantityItem.food
            let cell = tableView.dequeueReusableCell(withIdentifier: "quantityCell", for: indexPath) as! ItemQuantityTableViewCell
            cell.quantityCollectionView.didSelectQuantity = { quantity in
                switch quantity {
                case .none:
                    self.delete(quantityItem.food)
                case .some(let amount):
                    food.quantity = amount
                    self.tableView.reloadData()
                    self.updateUI()
                    self.viewModel.finishEditing()
                }
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = viewModel.item(for: indexPath)!
        switch item.key {
        case .food:
            return UITableViewAutomaticDimension
        case .quantity:
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.item(for: indexPath)!
        switch item.key {
        case .food:
            let foodItem = item as! FoodBagItem
            let food = foodItem.food
            let foodViewController = FoodViewController()
            foodViewController.food = food
            //foodViewController.navigationItemTitle = key.rawValue
            foodViewController.didGoBack = { foodViewController in
                self.tableView.reloadData()
                self.updateUI()
            }
            navigationController?.pushViewController(foodViewController, animated: true)
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let foodItem = viewModel.item(for: indexPath) as? FoodBagItem {
                delete(foodItem.food)
            }
        }
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
