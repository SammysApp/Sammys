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
    
    let items: Foods! = FoodsDataStore.shared.foods
    let choices: [Choice] = [.size, .lettuce, .vegetables, .toppings, .dressings]
    
    var salad = Salad()
    var currentChoiceIndex = 0 {
        didSet {
            if isViewLoaded { handleNewChoice() }
        }
    }
    var currentItemIndex = 0 {
        didSet {
            if isViewLoaded { updateUI(for: currentChoice) }
        }
    }
    var hasSelectedOnce = false
    var isEditingFood = false
    var finishEditing: (() -> Void)?
    
    var currentChoice: Choice {
        get {
            return choices[currentChoiceIndex]
        } set {
            currentChoiceIndex = choices.index(of: newValue)!
        }
    }
    
    // MARK: IBOutlets & View Properties
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var itemsLabel: UILabel!
    @IBOutlet var itemStackView: UIStackView!
    @IBOutlet var itemLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var priceButton: UIButton!
    
    let green = UIColor(named: "Flora")
    var tableViewIsShowing = false
    var tableViewConstraints: [NSLayoutConstraint] = []
    let flowCollectionViewLayout = UICollectionViewFlowLayout()
    let layout = AnimatedCollectionViewLayout()
    var isCollectionViewAnimating = false
    var isLayoutAnimated: Bool {
        return collectionView.collectionViewLayout.isKind(of: AnimatedCollectionViewLayout.self)
    }
    
    enum Choice: String {
        case size = "Size", lettuce = "Lettuce", vegetables = "Vegetables", toppings = "Toppings", dressings = "Dressings"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.sendSubview(toBack: collectionView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableViewConstraints = [
            tableView.topAnchor.constraint(equalTo: itemsLabel.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ]
        
        let animator = LinearCardAttributesAnimator(itemSpacing: 0.4, scaleRate: 0.75)
        layout.animator = animator
        layout.scrollDirection = .horizontal
        
        // selected once is true if editing
        hasSelectedOnce = isEditingFood
        
        updateUI(for: currentChoice)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    func updateUI(for choice: Choice) {
        itemsLabel.text = choice.rawValue
        nextButton.setTitle("Next", for: .normal)
        
        switch choice {
        case .size:
            priceLabel.isHidden = false
            itemLabel.isHidden = false
            itemLabel.text = items.salad.sizes[currentItemIndex].name
            priceLabel.text = "$\(items.salad.sizes[currentItemIndex].price)"
        case .lettuce:
            priceLabel.isHidden = true
            itemLabel.isHidden = false
            itemLabel.text = items.salad.lettuce[currentItemIndex].name
        case .vegetables, .toppings, .dressings:
            priceLabel.isHidden = true
            itemLabel.isHidden = true
        }
        
        if choice == choices.first {
            backButton.isHidden = false
            if hasSelectedOnce {
                nextButton.isHidden = false
            }
        } else if choice == choices.last {
            backButton.isHidden = false
            nextButton.isHidden = false
            nextButton.setTitle(isEditingFood ? "Done" : "Review", for: .normal)
        } else {
            backButton.isHidden = false
            nextButton.isHidden = false
        }
        
        if hasSelectedOnce {
            priceButton.isHidden = false
            priceButton.setTitle("$\(salad.price)", for: .normal)
        }
        
        updateCollectionView()
    }
    
    func updateCollectionView() {
        switch currentChoice {
        case .vegetables, .toppings, .dressings:
            collectionView.alwaysBounceHorizontal = false
            collectionView.alwaysBounceVertical = true
            collectionView.isPagingEnabled = false
            collectionView.collectionViewLayout = flowCollectionViewLayout
        default:
            collectionView.alwaysBounceHorizontal = true
            collectionView.alwaysBounceVertical = false
            collectionView.isPagingEnabled = true
            collectionView.collectionViewLayout = layout
        }
    }
    
    /**
     Updates `self.centerPoint` to the centermost cell's `indexPath.row` property.
    */
    func updateCurrentItemIndex() {
        let centerPoint = view.convert(view.center, to: collectionView)
        currentItemIndex = collectionView.indexPathForItem(at: centerPoint)!.row
    }
    
    func handleNewChoice() {
        collectionView.reloadData()
        tableView.reloadData()
        collectionView.setContentOffset(CGPoint(x: 0, y: collectionView.contentOffset.y), animated: false)
        currentItemIndex = 0
    }
    
    func showAddViewController() {
        if let addViewController = AddViewController.storyboardInstance() as? AddViewController {
            addViewController.food = salad
            addViewController.delegate = self
            navigationController?.pushViewController(addViewController, animated: true)
        }
    }
    
    /**
     Called when done editing.
    */
    func done() {
        finishEditing?()
        navigationController?.popViewController(animated: true)
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
    
    @IBAction func showAdd(_ sender: UIButton) {
        if isEditingFood {
            done()
        } else {
            showAddViewController()
        }
    }
    
    @IBAction func next(_ sender: UIButton) {
        if currentChoice == choices.last {
            if isEditingFood {
                done()
            } else {
                showAddViewController()
            }
        } else {
            currentChoiceIndex += 1
            handleNewChoice()
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        if currentChoice == choices.first {
            navigationController?.popViewController(animated: true)
        } else {
            currentChoiceIndex -= 1
            handleNewChoice()
        }
    }
}

// MARK: - Helpers for Collection and Table View
extension ItemsViewController {
    var numberOfItems: Int {
        switch currentChoice {
        case .size:
            return items.salad.sizes.count
        case .lettuce:
            return items.salad.lettuce.count
        case .vegetables:
            return items.salad.vegetables.count
        case .toppings:
            return items.salad.toppings.count
        case .dressings:
            return items.salad.dressings.count
        }
    }
}

extension ItemsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as! ItemCollectionViewCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? ItemCollectionViewCell {
            cell.layer.cornerRadius = 20
            cell.titleLabel.text = nil
            
            func selected() {
                cell.backgroundColor = .white
                cell.layer.borderColor = green?.cgColor
                cell.layer.borderWidth = 5
            }
            
            func unselected() {
                cell.backgroundColor = green
                cell.layer.borderWidth = 0
            }
            
            switch currentChoice {
            case .size:
                let size = items.salad.sizes[indexPath.row]
                if size == salad.size {
                    selected()
                } else {
                    unselected()
                }
            case .lettuce:
                let lettuce = items.salad.lettuce[indexPath.row]
                if salad.lettuce.contains(lettuce) {
                    selected()
                } else {
                    unselected()
                }
            case .vegetables:
                let vegetable = items.salad.vegetables[indexPath.row]
                cell.titleLabel.text = vegetable.name
                if salad.vegetables.contains(vegetable) {
                    selected()
                } else {
                    unselected()
                }
            case .toppings:
                let topping = items.salad.toppings[indexPath.row]
                cell.titleLabel.text = topping.name
                if salad.toppings.contains(topping) {
                    selected()
                } else {
                    unselected()
                }
            case .dressings:
                let dressing = items.salad.dressings[indexPath.row]
                cell.titleLabel.text = dressing.name
                if salad.dressings.contains(dressing) {
                    selected()
                } else {
                    unselected()
                }
            }
        }
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
        
        switch currentChoice {
        case .size:
            let size = items.salad.sizes[indexPath.row]
            cell.textLabel?.text = size.name
        case .lettuce:
            let lettuce = items.salad.lettuce[indexPath.row]
            cell.textLabel?.text = lettuce.name
        case .vegetables:
            let vegetable = items.salad.vegetables[indexPath.row]
            cell.textLabel?.text = vegetable.name
        case .toppings:
            let topping = items.salad.toppings[indexPath.row]
            cell.textLabel?.text = topping.name
        case .dressings:
            let dressing = items.salad.dressings[indexPath.row]
            cell.textLabel?.text = dressing.name
        }
        
        return cell
    }
}

extension ItemsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
        case .toppings:
            let topping = items.salad.toppings[indexPath.row]
            if salad.toppings.contains(topping) {
                salad.toppings.remove(topping)
            } else {
                salad.toppings.append(topping)
            }
        case .dressings:
            let dressing = items.salad.dressings[indexPath.row]
            if salad.dressings.contains(dressing) {
                salad.dressings.remove(dressing)
            } else {
                salad.dressings.append(dressing)
            }
        }
        
        hasSelectedOnce = true
        currentItemIndex = indexPath.row
        
        if currentChoice == .size || currentChoice == .lettuce {
            let currentItemIndexOffsetX = CGFloat(currentItemIndex) * collectionView.bounds.size.width
            if collectionView.contentOffset.x != currentItemIndexOffsetX {
                isCollectionViewAnimating = true
                collectionView.setContentOffset(CGPoint(x: currentItemIndexOffsetX, y: collectionView.contentOffset.y), animated: true)
            }
        }
        
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch currentChoice {
        case .vegetables, .toppings, .dressings:
            let size = collectionView.frame.width/2 - 15
            return CGSize(width: size, height: size)
        default:
            return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height/1.5)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch currentChoice {
        case .vegetables, .toppings, .dressings:
            return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        default:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch currentChoice {
        case .vegetables, .toppings, .dressings:
            return 10
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        switch currentChoice {
        case .vegetables, .toppings, .dressings:
            return 10
        default:
            return .greatestFiniteMagnitude
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isCollectionViewAnimating = false
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if currentChoice == .size || currentChoice == .lettuce {
            if isLayoutAnimated && !isCollectionViewAnimating {
                updateCurrentItemIndex()
            }
        }
    }
}

extension ItemsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

protocol Editable {
    func edit(for title: String)
}

extension ItemsViewController: Editable {
    func edit(for title: String) {
        if let choice = Choice(rawValue: title) {
            currentChoice = choice
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