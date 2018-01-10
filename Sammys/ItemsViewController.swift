//
//  ItemsViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/4/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class ItemsViewController: UIViewController, Storyboardable {
    typealias ViewController = ItemsViewController
    
    let items: Items! = ItemsDataStore.shared.items
    let choices: [Choice] = [.size, .lettuce, .vegetables]
    
    var salad = Salad()
    var currentChoiceIndex = 0
    var currentIndex = 0 {
        didSet {
            updateUI(for: currentChoice)
        }
    }
    var hasSelectedOnce = false
    
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
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet var animatedCollectionViewLayout: AnimatedCollectionViewLayout!
    
    let green = UIColor(named: "Flora")
    var tableViewIsShowing = false
    var tableViewConstraints: [NSLayoutConstraint] = []
    let vegCollectionViewLayout = UICollectionViewFlowLayout()
    
    enum Choice: String {
        case size = "Size", lettuce = "Lettuce", vegetables = "Vegetables"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let animator = LinearCardAttributesAnimator(itemSpacing: 0.4, scaleRate: 0.75)
        animatedCollectionViewLayout.animator = animator
        view.sendSubview(toBack: collectionView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableViewConstraints = [
            tableView.topAnchor.constraint(equalTo: itemsLabel.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ]
        
        updateUI(for: currentChoice)
    }
    
    func updateUI(for choice: Choice) {
        itemsLabel.text = choice.rawValue
        nextButton.setTitle("Next", for: .normal)
        
        switch choice {
        case .size:
            priceLabel.isHidden = false
            itemLabel.isHidden = false
            itemLabel.text = items.salad.sizes[currentIndex].name
            priceLabel.text = "$\(items.salad.sizes[currentIndex].price)"
        case .lettuce:
            priceLabel.isHidden = true
            itemLabel.isHidden = false
            itemLabel.text = items.salad.lettuce[currentIndex].name
        case .vegetables:
            priceLabel.isHidden = true
            itemLabel.isHidden = true
        }
        
        if choice == choices.first {
            backButton.isHidden = true
            if hasSelectedOnce {
                nextButton.isHidden = false
            }
        } else if choice == choices.last {
            backButton.isHidden = false
            nextButton.isHidden = false
            nextButton.setTitle("Add", for: .normal)
        } else {
            backButton.isHidden = false
            nextButton.isHidden = false
        }
        
        updateCollectionView()
    }
    
    func updateCollectionView() {
        switch currentChoice {
        case .vegetables:
            collectionView.alwaysBounceHorizontal = false
            collectionView.alwaysBounceVertical = true
            collectionView.isPagingEnabled = false
            collectionView.collectionViewLayout = vegCollectionViewLayout
        default:
            collectionView.alwaysBounceHorizontal = true
            collectionView.alwaysBounceVertical = false
            collectionView.isPagingEnabled = true
            collectionView.collectionViewLayout = animatedCollectionViewLayout
        }
    }
    
    func didSelect(at indexPath: IndexPath) {
        hasSelectedOnce = true
        updateUI(for: currentChoice)
    }
    
    func handleNewChoice() {
        updateUI(for: choices[currentChoiceIndex])
        collectionView.reloadData()
        tableView.reloadData()
        collectionView.setContentOffset(CGPoint(x: 0, y: collectionView.contentOffset.y), animated: false)
        currentIndex = 0
    }
    
    func addSalad() {
        BagDataStore.shared.add(salad)
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
    
    @IBAction func showBag(_ sender: UIButton) {
        present(BagViewController.storyboardInstance(), animated: true, completion: nil)
    }
    
    @IBAction func next(_ sender: UIButton) {
        if currentChoice == choices.last {
            addSalad()
        } else {
            currentChoiceIndex += 1
            nextButton.isHidden = true
            handleNewChoice()
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        if currentChoice != choices.first {
            currentChoiceIndex -= 1
            handleNewChoice()
        }
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
        
        cell.backgroundColor = .green
        cell.layer.borderColor = green?.cgColor
        cell.layer.borderWidth = 0
        cell.layer.cornerRadius = 20
        switch currentChoice {
        case .size:
            let size = items.salad.sizes[indexPath.row]
            if size == salad.size {
                cell.backgroundColor = .white
                cell.layer.borderWidth = 5
            }
        case .lettuce:
            let lettuce = items.salad.lettuce[indexPath.row]
            if salad.lettuce.contains(lettuce) {
                cell.backgroundColor = .white
                cell.layer.borderWidth = 5
            }
        case .vegetables:
            let vegetable = items.salad.vegetables[indexPath.row]
            if salad.vegetables.contains(vegetable) {
                cell.backgroundColor = .white
                cell.layer.borderWidth = 5
            }
        }
        
        return cell
    }
}

extension ItemsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        return cell
    }
}

extension ItemsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelect(at: indexPath)
        switch currentChoice {
        case .size:
            salad.size = items.salad.sizes[indexPath.row]
        case .lettuce:
            let lettuce = items.salad.lettuce[indexPath.row]
            if salad.lettuce.contains(lettuce) {
                salad.lettuce.remove(lettuce)
            } else {
                salad.lettuce.append(lettuce)
            }
        case .vegetables:
            let vegetable = items.salad.vegetables[indexPath.row]
            if salad.vegetables.contains(vegetable) {
                salad.vegetables.remove(vegetable)
            } else {
                salad.vegetables.append(vegetable)
            }
        }
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch currentChoice {
        case .vegetables:
            let size = collectionView.frame.width/2 - 10
            return CGSize(width: size, height: size)
        default:
            return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height/1.5)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        switch currentChoice {
        case .vegetables:
            return 10
        default:
            return .greatestFiniteMagnitude
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if collectionView.collectionViewLayout == animatedCollectionViewLayout {
            let centerPoint = view.convert(view.center, to: collectionView)
            currentIndex = collectionView.indexPathForItem(at: centerPoint)!.row
        }
    }
}

// MARK: - Protocols

protocol Storyboardable {
    associatedtype ViewController: UIViewController
}

extension Storyboardable where Self: UIViewController {
    static func storyboardInstance() -> UIViewController {
        let className = String(describing: ViewController.self)
        let storyboard = UIStoryboard(name: className, bundle: nil)
        return storyboard.instantiateInitialViewController()!
    }
}

// MARK: - Extensions

extension Array where Element: Equatable {
    mutating func remove(_ element: Element) {
        self = self.filter { $0 != element }
    }
}
