//
//  ItemsViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/4/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ItemsViewController: UIViewController, ItemsViewModelDelegate {
    private var viewModel = ItemsViewModel()

    var currentItemIndex = 0 {
        didSet {
            if isViewLoaded { updateUI() }
        }
    }
    
    var hasSelectedOnce = false
    var isEditingFood = false
    
    /// Closure called once done editing.
    var didFinishEditing: (() -> Void)?
    
    lazy var choiceDidChange: () -> () = {
        self.handleNewChoice()
    }
    
    // MARK: - IBOutlets & View Properties
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var itemTypeLabel: UILabel!
    @IBOutlet var itemStackView: UIStackView!
    @IBOutlet var itemLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var finishButton: UIButton!
    @IBOutlet var modifierView: UIVisualEffectView!
    @IBOutlet var modifierCollectionView: ModifierCollectionView!
    @IBOutlet var activityIndicatorView: NVActivityIndicatorView! {
        didSet {
            activityIndicatorView.color = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        }
    }
    
    let flowCollectionViewLayout = UICollectionViewFlowLayout()
    let layout = AnimatedCollectionViewLayout()
    let modifierViewEffect = UIBlurEffect(style: .dark)
    var isCollectionViewAnimating = false
    var isLayoutAnimated: Bool {
        return collectionView.collectionViewLayout.isKind(of: AnimatedCollectionViewLayout.self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    struct Constants {
        static let next = "Next"
        static let done = "Done"
        static let finish = "Finish"
        static let backAlertTitle = "You sure?"
        static let backAlertMessage = "This will disregard all of your work."
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up for loading food data.
        activityIndicatorView.startAnimating()
        itemStackView.isHidden = true
        itemTypeLabel.isHidden = true
        
        viewModel.delegate = self
        viewModel.setData {
            self.activityIndicatorView.stopAnimating()
            self.itemStackView.isHidden = false
            self.itemTypeLabel.isHidden = false
            self.collectionView.reloadData()
            self.updateUI()
        }
        
        view.sendSubview(toBack: collectionView)
        
        // Set up layout for collection view.
        let animator = LinearCardAttributesAnimator(itemSpacing: 0.4, scaleRate: 0.75)
        layout.animator = animator
        layout.scrollDirection = .horizontal
        
        // Set selected to true if editing (otherwise can't tap next).
        hasSelectedOnce = isEditingFood
        
        nextButton.layer.cornerRadius = 10
        backButton.layer.cornerRadius = 10
        
        modifierCollectionView.viewModel.didSelect = { self.didSelect($0, for: $1) }
        modifierCollectionView.viewModel.shouldShowSelected = viewModel.modifierIsSelected
        
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    // MARK: -
    
    func updateUI() {
        if let item = viewModel.items[safe: currentItemIndex] {
            itemLabel.text = item.name
        }
        
        itemTypeLabel.text = viewModel.itemTypeLabelText
        priceLabel.text = viewModel.priceLabelText(at: currentItemIndex)
        itemLabel.isHidden = viewModel.shouldHideItemLabel
        priceLabel.isHidden = viewModel.shouldHidePriceLabel
        
        updateNextButton()
        updateFinishButton()
        updateCollectionView()
    }
    
    func updateCollectionView() {
        switch viewModel.currentViewLayoutState {
        case .horizontal:
            collectionView.alwaysBounceHorizontal = true
            collectionView.alwaysBounceVertical = false
            collectionView.isPagingEnabled = true
            collectionView.collectionViewLayout = layout
        case .vertical:
            collectionView.alwaysBounceHorizontal = false
            collectionView.alwaysBounceVertical = true
            collectionView.isPagingEnabled = false
            collectionView.collectionViewLayout = flowCollectionViewLayout
        }
    }
    
    func updateNextButton() {
        nextButton.setTitle(Constants.next, for: .normal)
        if viewModel.atFirstChoice && !hasSelectedOnce {
            nextButton.isHidden = true
        } else {
            nextButton.isHidden = false
            if viewModel.atLastChoice {
                nextButton.setTitle(isEditingFood ? Constants.done : Constants.finish, for: .normal)
            }
        }
    }
    
    func updateFinishButton() {
        if hasSelectedOnce {
            if !viewModel.atLastChoice { finishButton.isHidden = false }
            else { finishButton.isHidden = true }
        } else { finishButton.isHidden = true }
    }
    
    func updateTopView(for contentOffsetY: CGFloat) {
        if contentOffsetY > 0 {
            UIView.animate(withDuration: 0.25, animations: { [self.itemTypeLabel, self.finishButton].forEach { $0.alpha = 0 } })
        } else {
            UIView.animate(withDuration: 0.25, animations: { [self.itemTypeLabel, self.finishButton].forEach { $0.alpha = 1 } })
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
        switch viewModel.currentViewLayoutState {
        case .horizontal:
            collectionView.setContentOffset(CGPoint(x: 0, y: collectionView.contentOffset.y), animated: false)
        case .vertical:
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        }
        currentItemIndex = 0
    }
    
    /// Sets to proper x content offset for item index.
    func setContentOffset(for itemIndex: Int) {
        if viewModel.currentViewLayoutState == .horizontal {
            let itemIndexOffsetX = CGFloat(itemIndex) * collectionView.bounds.size.width
            if collectionView.contentOffset.x != itemIndexOffsetX {
                isCollectionViewAnimating = true
                collectionView.setContentOffset(CGPoint(x: itemIndexOffsetX, y: collectionView.contentOffset.y), animated: true)
            }
        }
    }
    
    func showAddViewController() {
        if let addViewController = AddViewController.storyboardInstance() as? AddViewController {
            addViewController.viewModel = AddViewModel(food: viewModel.food, editDelegate: viewModel)
            navigationController?.pushViewController(addViewController, animated: true)
        }
    }
    
    func showModifiers(for item: Item) {
        modifierCollectionView.viewModel.item = item
        modifierCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        // Set up for animation.
        modifierView.effect = nil
        modifierView.isHidden = false
        modifierView.contentView.isHidden = false
        modifierView.contentView.alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.modifierView.effect = self.modifierViewEffect
            self.modifierView.contentView.alpha = 1
        }
    }
    
    func hideModifiers() {
        UIView.animate(withDuration: 0.25, animations: {
            self.modifierView.effect = nil
            self.modifierView.contentView.alpha = 0
        }) {
            guard $0 else { return }
            self.modifierView.isHidden = true
            self.modifierView.contentView.isHidden = true
        }
    }
    
    func presentBackAlertController(didChooseBack: @escaping () -> Void) {
        let checkoutAlertController = UIAlertController(title: Constants.backAlertTitle, message: Constants.backAlertMessage, preferredStyle: .alert)
        [UIAlertAction(title: "Go Back", style: .default, handler: { action in
            didChooseBack()
        }),
        UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            checkoutAlertController.dismiss(animated: true, completion: nil)
        })].forEach { checkoutAlertController.addAction($0) }
        present(checkoutAlertController, animated: true, completion: nil)
    }
    
    func didSelectItem(at index: Int) {
        viewModel.handleItemSelection(at: index)
        currentItemIndex = index
        setContentOffset(for: currentItemIndex)
        hasSelectedOnce = true
        collectionView.reloadData()
    }
    
    func didSelect(_ modifier: Modifier, for item: Item) {
        viewModel.toggleModifier(modifier, for: item)
        modifierCollectionView.reloadData()
        collectionView.reloadData()
    }
    
    /// Called once done editing.
    func finishEditing() {
        didFinishEditing?()
        navigationController?.popViewController(animated: true)
    }
    
    /// Gets the cell view model for the index path from the view model.
    func cellViewModel(for indexPath: IndexPath) -> CollectionViewCellViewModel {
        return viewModel.cellViewModels(for: collectionView.bounds)[indexPath.item]
    }
    
    func resetFood(to food: Food) {
        viewModel.resetFood(to: food)
    }
    
    func edit(for itemType: ItemType) {
        viewModel.edit(for: itemType)
    }
    
    // MARK: - IBActions
    @IBAction func didTapNext(_ sender: UIButton) {
        if viewModel.atLastChoice {
            if isEditingFood {
                finishEditing()
            } else {
                showAddViewController()
            }
        } else {
            viewModel.goToNextChoice()
        }
    }
    
    @IBAction func didTapBack(_ sender: UIButton) {
        if viewModel.atFirstChoice {
            if hasSelectedOnce {
                presentBackAlertController {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                navigationController?.popViewController(animated: true)
            }
        } else {
            viewModel.goToPreviousChoice()
        }
    }
    
    @IBAction func didTapFinish(_ sender: UIButton) {
        if isEditingFood {
            finishEditing()
        } else {
            showAddViewController()
        }
    }
    
    
    @IBAction func didTapView(_ sender: UITapGestureRecognizer) {
        if !modifierView.contentView.isHidden {
            hideModifiers()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ItemsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = cellViewModel(for: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: model.identifier, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let model = cellViewModel(for: indexPath)
        model.commands[.configuration]?.perform(parameters: CommandParameters(cell: cell))
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ItemsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = cellViewModel(for: indexPath)
        if let cell = collectionView.cellForItem(at: indexPath) {
            model.commands[.selection]?.perform(parameters: CommandParameters(cell: cell))
        }
        didSelectItem(at: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let model = cellViewModel(for: indexPath)
        return model.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return viewModel.collectionViewInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return viewModel.collectionViewMinimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return viewModel.collectionViewMinimumInteritemSpacing
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y + view.safeAreaInsets.top
        updateTopView(for: contentOffsetY)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isCollectionViewAnimating = false
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if viewModel.currentViewLayoutState == .horizontal {
            if isLayoutAnimated && !isCollectionViewAnimating {
                updateCurrentItemIndex()
            }
        }
    }
}

extension ItemsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let touchLocation = touch.location(in: self.view)
        return !modifierCollectionView.frame.contains(touchLocation)
    }
}

extension ItemsViewController: Storyboardable {
    typealias ViewController = ItemsViewController
}
