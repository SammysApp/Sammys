//
//  ItemsViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/4/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class ItemsViewController: UIViewController {
    let items: Items! = ItemsDataStore.shared.items
    let salad = Salad()
    let choices: [Choice] = [.size, .lettuce, .vegetables]
    var currentChoiceIndex = 0
    var currentIndex = 0 {
        didSet {
            setup(for: currentChoice)
        }
    }
    
    var currentChoice: Choice {
        return choices[currentChoiceIndex]
    }
    
    // MARK: IBOutlets & View Properties
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var itemsLabel: UILabel!
    @IBOutlet weak var itemStackView: UIStackView!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    var tableViewIsShowing = false
    var tableViewConstraints: [NSLayoutConstraint] = []
    
    enum Choice: String {
        case size = "Size", lettuce = "Lettuce", vegetables = "Vegetables"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let layout = collectionView.collectionViewLayout as? AnimatedCollectionViewLayout {
            let animator = LinearCardAttributesAnimator(itemSpacing: 0.4, scaleRate: 0.75)
            layout.animator = animator
        }
        view.sendSubview(toBack: collectionView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableViewConstraints = [
            tableView.topAnchor.constraint(equalTo: itemsLabel.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ]
        
        setup(for: currentChoice)
    }
    
    func setup(for choice: Choice) {
        itemsLabel.text = choice.rawValue
        switch choice {
        case .size:
            priceLabel.isHidden = false
            itemLabel.text = items.salad.sizes[currentIndex].name
            priceLabel.text = String(items.salad.sizes[currentIndex].price)
        case .lettuce:
            priceLabel.isHidden = true
            itemLabel.text = items.salad.lettuce[currentIndex].name
        case .vegetables:
            priceLabel.isHidden = true
            itemLabel.text = items.salad.vegetables[currentIndex].name
        }
    }
    
    func didSelect(at indexPath: IndexPath) {
        nextButton.isHidden = false
    }
    
    // MARK: IBActions
    
    @IBAction func showTableView(_ sender: UIButton) {
        if tableViewIsShowing {
            tableView.removeFromSuperview()
            tableViewConstraints.forEach { $0.isActive = false }
            
            collectionView.isHidden = false
            itemStackView.isHidden = false
            tableViewIsShowing = false
        } else {
            view.addSubview(tableView)
            tableViewConstraints.forEach { $0.isActive = true }
            
            collectionView.isHidden = true
            itemStackView.isHidden = true
            tableViewIsShowing = true
        }
    }
    
    @IBAction func next(_ sender: UIButton) {
        nextButton.isHidden = true
        currentChoiceIndex += 1
        setup(for: choices[currentChoiceIndex])
        collectionView.reloadData()
        tableView.reloadData()
    }
}

extension ItemsViewController: UICollectionViewDataSource {
    var numberOfItems: Int {
        switch currentChoice {
        case .size:
            return items.salad.sizes.count
        case .lettuce:
            return items.salad.lettuce.count
        case .vegetables:
            return items.salad.vegetables.count
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath)
        cell.layer.cornerRadius = 20
        return cell
    }
}

extension ItemsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        return cell
    }
}

extension ItemsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelect(at: indexPath)
        if let cell = collectionView.cellForItem(at: indexPath) {
            let borderColor = cell.backgroundColor!
            cell.backgroundColor = .white
            cell.layer.borderColor = borderColor.cgColor
            cell.layer.borderWidth = 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height/1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .greatestFiniteMagnitude
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let centerPoint = view.convert(view.center, to: collectionView)
        currentIndex = collectionView.indexPathForItem(at: centerPoint)!.row
    }
}
