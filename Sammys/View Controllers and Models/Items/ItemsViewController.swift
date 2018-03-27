//
//  ItemsViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/4/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

typealias Choice = SaladItemType

class ItemsViewController: UIViewController, Storyboardable {
    typealias ViewController = ItemsViewController
    
    let viewModel = ItemsViewModel()
    var salad = Salad()
    
    let choices = Choice.all
    
    var currentChoiceIndex = 0 {
        didSet {
            if isViewLoaded { handleNewChoice() }
        }
    }
    
    var currentChoice: Choice {
        get {
            return choices[currentChoiceIndex]
        } set {
            currentChoiceIndex = choices.index(of: newValue)!
        }
    }
    
    var currentItemIndex = 0 {
        didSet {
            if isViewLoaded { updateUI() }
        }
    }
    
    var hasSelectedOnce = false
    var isEditingFood = false
    
    /// Closure called once done editing.
    var didFinishEditing: (() -> Void)?
    
    // MARK: - IBOutlets & View Properties
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var itemsLabel: UILabel!
    @IBOutlet var itemStackView: UIStackView!
    @IBOutlet var itemLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var priceButton: UIButton!
    
    let flowCollectionViewLayout = UICollectionViewFlowLayout()
    let layout = AnimatedCollectionViewLayout()
    var isCollectionViewAnimating = false
    var isLayoutAnimated: Bool {
        return collectionView.collectionViewLayout.isKind(of: AnimatedCollectionViewLayout.self)
    }
    
    enum CellIdentifier: String {
        case itemCell
    }
    
    struct Constants {
        static let next = "Next"
        static let done = "Done"
        static let review = "Review"
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.sendSubview(toBack: collectionView)
        
        // Set up layout for collection view.
        let animator = LinearCardAttributesAnimator(itemSpacing: 0.4, scaleRate: 0.75)
        layout.animator = animator
        layout.scrollDirection = .horizontal
        
        // Set selected to true if editing (otherwise can't go back).
        hasSelectedOnce = isEditingFood
        
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    // MARK: -
    
    func updateUI() {
        itemsLabel.text = currentChoice.title
        
        switch currentChoice {
        case .size:
            priceLabel.isHidden = false
            itemLabel.isHidden = false
//            itemLabel.text = foods.salad.sizes[currentItemIndex].name
//            priceLabel.text = "$\(foods.salad.sizes[currentItemIndex].price)"
        case .lettuce:
            priceLabel.isHidden = true
            itemLabel.isHidden = false
//            itemLabel.text = foods.salad.lettuce[currentItemIndex].name
        case .vegetable, .topping, .dressing:
            priceLabel.isHidden = true
            itemLabel.isHidden = true
        case .extra: break
        }
        
        updateNextAndBackButtons()
        updateCollectionView()
    }
    
    func updateCollectionView() {
        switch currentChoice {
        case .vegetable, .topping, .dressing:
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
    
    func updateNextAndBackButtons() {
        nextButton.setTitle(Constants.next, for: .normal)
        
        if currentChoice == choices.first {
            backButton.isHidden = false
            if hasSelectedOnce {
                nextButton.isHidden = false
            }
        } else if currentChoice == choices.last {
            backButton.isHidden = false
            nextButton.isHidden = false
            nextButton.setTitle(isEditingFood ? Constants.done : Constants.review, for: .normal)
        } else {
            backButton.isHidden = false
            nextButton.isHidden = false
        }
        
        if hasSelectedOnce {
            priceButton.isHidden = false
            priceButton.setTitle("$\(salad.price)", for: .normal)
        }
    }
    
    /// Updates `self.centerPoint` to the centermost cell's `indexPath.row` property.
    func updateCurrentItemIndex() {
        let centerPoint = view.convert(view.center, to: collectionView)
        if let row = collectionView.indexPathForItem(at: centerPoint)?.row {
            currentItemIndex = row
        }
    }
    
    /// Call when new choice selected.
    func handleNewChoice() {
        collectionView.reloadData()
        collectionView.setContentOffset(CGPoint(x: 0, y: collectionView.contentOffset.y), animated: false)
        currentItemIndex = 0
    }
    
    /// Sets to proper x content offset for item index.
    func setContentOffset(for itemIndex: Int) {
        if currentChoice == .size || currentChoice == .lettuce {
            let itemIndexOffsetX = CGFloat(itemIndex) * collectionView.bounds.size.width
            if collectionView.contentOffset.x != itemIndexOffsetX {
                isCollectionViewAnimating = true
                collectionView.setContentOffset(CGPoint(x: itemIndexOffsetX, y: collectionView.contentOffset.y), animated: true)
            }
        }
    }
    
    func showAddViewController() {
        if let addViewController = AddViewController.storyboardInstance() as? AddViewController {
            addViewController.food = salad
            addViewController.editDelegate = self
            navigationController?.pushViewController(addViewController, animated: true)
        }
    }
    
    /// Called once done editing.
    func finishEditing() {
        didFinishEditing?()
        navigationController?.popViewController(animated: true)
    }
    
    func cellViewModel(for indexPath: IndexPath) -> CellViewModel {
        return viewModel.cellViewModels(for: currentChoice, contextBounds: collectionView.bounds)[indexPath.item]
    }
    
    // MARK: - IBActions
    @IBAction func didTapNext(_ sender: UIButton) {
        if currentChoice == choices.last {
            if isEditingFood {
                finishEditing()
            } else {
                showAddViewController()
            }
        } else {
            currentChoiceIndex += 1
            handleNewChoice()
        }
    }
    
    @IBAction func didTapBack(_ sender: UIButton) {
        if currentChoice == choices.first {
            navigationController?.popViewController(animated: true)
        } else {
            currentChoiceIndex -= 1
            handleNewChoice()
        }
    }
    
    @IBAction func didTapPrice(_ sender: UIButton) {
        if isEditingFood {
            finishEditing()
        } else {
            showAddViewController()
        }
    }
}

extension ItemsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems(for: currentChoice)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = cellViewModel(for: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: model.identifier, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let model = cellViewModel(for: indexPath)
        model.commands[.configuration]?.perform(cell: cell)
    }
}

extension ItemsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = cellViewModel(for: indexPath)
        if let cell = collectionView.cellForItem(at: indexPath) {
            model.commands[.selection]?.perform(cell: cell)
        }
        hasSelectedOnce = true
        currentItemIndex = indexPath.row
        setContentOffset(for: currentItemIndex)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let model = cellViewModel(for: indexPath)
        return model.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch currentChoice {
        case .vegetable, .topping, .dressing:
            return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        default:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch currentChoice {
        case .vegetable, .topping, .dressing:
            return 10
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        switch currentChoice {
        case .vegetable, .topping, .dressing:
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

protocol Editable {
    func edit(for title: String)
}

protocol Storyboardable {
    associatedtype ViewController: UIViewController
}

extension Choice {
    init?(_ title: String) {
        if let choice = SaladItemType.type(for: title) {
            self = choice
        }
        return nil
    }
}

extension ItemsViewController: Editable {
    func edit(for title: String) {
        if let choice = Choice(title) {
            currentChoice = choice
        }
    }
}

extension Storyboardable where Self: UIViewController {
    static func storyboardInstance() -> UIViewController {
        let className = String(describing: ViewController.self)
        let storyboard = UIStoryboard(name: className, bundle: nil)
        return storyboard.instantiateInitialViewController()!
    }
}

extension Array where Element: Equatable {
    mutating func remove(_ element: Element) {
        self = self.filter { $0 != element }
    }
}
