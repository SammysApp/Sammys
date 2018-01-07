//
//  ItemsViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/4/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class ItemsViewController: UIViewController {
    var currentIndex = 0 {
        didSet {
            itemLabel?.text = items[currentIndex]
        }
    }
    let items = ["Avocado", "Beets", "Cucumber", "Eggs", "Garlic"]
    
    // MARK: - IBOutlets & View Properties
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var itemsLabel: UILabel!
    @IBOutlet weak var itemStackView: UIStackView!
    @IBOutlet weak var itemLabel: UILabel!
    
    var tableViewIsShowing = false
    var tableViewConstraints: [NSLayoutConstraint] = []
    
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
        
        itemLabel.text = items[currentIndex]
    }
    
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
}

extension ItemsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
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
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
}

extension ItemsViewController: UICollectionViewDelegateFlowLayout {
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
