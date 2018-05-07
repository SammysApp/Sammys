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
    @IBOutlet var priceButton: UIButton!
    @IBOutlet var activityIndicatorView: NVActivityIndicatorView! {
        didSet {
            activityIndicatorView.color = UIColor(named: "Mocha")!
        }
    }
    
    let flowCollectionViewLayout = UICollectionViewFlowLayout()
    let layout = AnimatedCollectionViewLayout()
    var isCollectionViewAnimating = false
    var isLayoutAnimated: Bool {
        return collectionView.collectionViewLayout.isKind(of: AnimatedCollectionViewLayout.self)
    }
    
    struct Constants {
        static let next = "Next"
        static let done = "Done"
        static let review = "Review"
        static let backAlertTitle = "You sure? 🤨"
        static let backAlertMessage = "Going back now will disregard any of your hard work!"
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
        updatePriceButton()
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
                nextButton.setTitle(isEditingFood ? Constants.done : Constants.review, for: .normal)
            }
        }
    }
    
    func updatePriceButton() {
        if hasSelectedOnce {
            priceButton.isHidden = false
            priceButton.setTitle(viewModel.priceButtonTitle, for: .normal)
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
    
    func presentBackAlertController(didChooseBack: @escaping () -> Void) {
        let checkoutAlertController = UIAlertController(title: Constants.backAlertTitle, message: Constants.backAlertMessage, preferredStyle: .alert)
        [UIAlertAction(title: "All Good", style: .default, handler: { action in
            didChooseBack()
        }),
        UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            checkoutAlertController.dismiss(animated: true, completion: nil)
        })].forEach { checkoutAlertController.addAction($0) }
        present(checkoutAlertController, animated: true, completion: nil)
    }
    
    func didSelectItem(at index: Int) {
        viewModel.toggleItem(at: index)
        currentItemIndex = index
        setContentOffset(for: currentItemIndex)
        hasSelectedOnce = true
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
    
    @IBAction func didTapPrice(_ sender: UIButton) {
        if isEditingFood {
            finishEditing()
        } else {
            showAddViewController()
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

extension ItemsViewController: Storyboardable {
    typealias ViewController = ItemsViewController
}
