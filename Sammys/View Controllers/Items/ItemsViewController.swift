//
//  ItemsViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/4/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

enum ItemsViewLayoutState {
	case horizontal, vertical
}

protocol ItemsViewLayoutStateSpecifier {
	var state: ItemsViewLayoutState { get }
}

class ItemsViewController: UIViewController {
	typealias CellViewModel = ItemsViewModel.Section.CellViewModel
	
	/// Must be set for use by the view model.
	var viewModelParcel: ItemsViewModelParcel!
	private var viewModel: ItemsViewModel!
	
	let defaultViewLayoutState = ItemsViewLayoutState.horizontal
	let animatedCardCollectionViewLayout = AnimatedCollectionViewLayout()
	let flowCollectionViewLayout = UICollectionViewFlowLayout()
	let modifierViewEffect = UIBlurEffect(style: .dark)
	
	var currentViewLayoutState: ItemsViewLayoutState {
		guard let stateSpecifier = viewModel.itemCategory.value as? ItemsViewLayoutStateSpecifier else { return defaultViewLayoutState }
		return stateSpecifier.state
	}

    // MARK: - IBOutlets
    @IBOutlet var collectionView: UICollectionView!
	
    @IBOutlet var itemCategoryLabel: UILabel!
	@IBOutlet var totalPriceLabel: UILabel!
	
    @IBOutlet var itemDetailsStackView: UIStackView!
    @IBOutlet var itemNameLabel: UILabel!
    @IBOutlet var itemPriceLabel: UILabel!
    @IBOutlet var itemDescriptionLabel: UILabel!
	
	@IBOutlet var backButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var finishButton: UIButton!
	
    @IBOutlet var modifierView: UIVisualEffectView!
    @IBOutlet var modifierCollectionView: ModifierCollectionView!
	
    @IBOutlet var activityIndicatorView: NVActivityIndicatorView!

	// MARK: - Property Overrides
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
	
	struct Constants {
		static let itemCollectionViewCellXibName = "ItemCollectionViewCell"
		
		static let collectionViewContentInset: CGFloat = 10
		
		static let cardAnimatorItemSpacing: CGFloat = 0.4
		static let cardAnimatorScaleRate: CGFloat = 0.75
		
		static let bottomButtonsCornerRadius: CGFloat = 10
		
		static let topViewsUpdateAnimationDuration = 0.25
	}

    // MARK: - Lifecycle
	override func viewDidLoad() {
        super.viewDidLoad()
		
		viewModel = ItemsViewModel(viewDelegate: self, parcel: viewModelParcel)
		
		setupCollectionView()
		setupAnimatedCardCollectionViewLayout()
		setupBackButton()
		setupNextButton()
		
		viewModel.itemCategory.bindAndRun { self.didChangeItemCategory(with: $0) }
		viewModel.sections.bindAndRun { _ in self.collectionView.reloadData() }
		viewModel.centerCellViewModel.bindAndRun { cellViewModel in
			if let cellViewModel = cellViewModel { self.didCenter(at: cellViewModel) }
		}
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: true)
    }
	
	// MARK: - Setup
	func setupCollectionView() {
		collectionView.register(
			UINib(nibName: Constants.itemCollectionViewCellXibName, bundle: Bundle.main),
			forCellWithReuseIdentifier: ItemsViewModel.ItemCellIdentifier.itemCell.rawValue
		)
		collectionView.contentInset.right = Constants.collectionViewContentInset
		collectionView.contentInset.left = Constants.collectionViewContentInset
	}
	
	func setupAnimatedCardCollectionViewLayout() {
		let animator = LinearCardAttributesAnimator(
			itemSpacing: Constants.cardAnimatorItemSpacing,
			scaleRate: Constants.cardAnimatorScaleRate
		)
		animatedCardCollectionViewLayout.animator = animator
		animatedCardCollectionViewLayout.scrollDirection = .horizontal
	}
	
	func setupBackButton() {
		backButton.layer.cornerRadius = Constants.bottomButtonsCornerRadius
	}
	
	func setupNextButton() {
		nextButton.layer.cornerRadius = Constants.bottomButtonsCornerRadius
	}
	
	// MARK: - Update
	func updateCollectionView(for state: ItemsViewLayoutState) {
        switch state {
        case .horizontal:
            collectionView.alwaysBounceHorizontal = true
            collectionView.alwaysBounceVertical = false
            collectionView.isPagingEnabled = true
            collectionView.collectionViewLayout = animatedCardCollectionViewLayout
        case .vertical:
            collectionView.alwaysBounceHorizontal = false
            collectionView.alwaysBounceVertical = true
            collectionView.isPagingEnabled = false
            collectionView.collectionViewLayout = flowCollectionViewLayout
        }
    }

    func updateTopViews(forContentOffsetY contentOffsetY: CGFloat) {
        if contentOffsetY > 0 { toggleTopViewsHidden(true) }
		else { toggleTopViewsHidden(false) }
    }
	
	// MARK: - Methods
	func changeViewLayout(for state: ItemsViewLayoutState) {
		itemDetailsStackView.isHidden = state == .vertical
		updateCollectionView(for: state)
	}
	
	func toggleTopViewsHidden(_ shouldHide: Bool, animationDuration: TimeInterval = Constants.topViewsUpdateAnimationDuration) {
		UIView.animate(
			withDuration: animationDuration,
			animations: {
				[self.itemCategoryLabel, self.totalPriceLabel, self.finishButton]
				.forEach { $0.alpha = shouldHide ? 0 : 1 }
			}
		)
	}
	
	func didChangeItemCategory(with itemCategory: FoodItemCategory) {
		viewModel.setupData(for: itemCategory).catch { print($0) }
		itemCategoryLabel.text = itemCategory.name
		if let stateSpecifier = itemCategory as? ItemsViewLayoutStateSpecifier {
			changeViewLayout(for: stateSpecifier.state)
		} else { changeViewLayout(for: defaultViewLayoutState) }
	}
	
	func didCenter(at cellViewModel: CellViewModel) {
		itemNameLabel.text = cellViewModel.foodItem.name
		if let pricedFoodItem = cellViewModel.foodItem as? PricedFoodItem {
			itemPriceLabel.text = "\(pricedFoodItem.price)"
		}
	}
	
	func didSelect(_ cellViewModel: CellViewModel) {
		do { try viewModel.toggle(cellViewModel.foodItem) }
		catch { print(error) }
	}
	
	func presentAddFoodViewController() throws {
		let addFoodViewController = FoodViewController.storyboardInstance()
		addFoodViewController.viewModelParcel = try viewModel.addFoodViewModelParcel()
		present(addFoodViewController, animated: true, completion: nil)
	}

    // MARK: - IBActions
    @IBAction func didTapNext(_ sender: UIButton) {
		do {
			if viewModel.isAtLastItemCategory { try presentAddFoodViewController() }
			else { try viewModel.incrementItemCategory() }
		} catch { print(error) }
    }

    @IBAction func didTapBack(_ sender: UIButton) {
		do { try viewModel.decrementItemCategory() }
		catch { print(error) }
    }

    @IBAction func didTapFinish(_ sender: UIButton) {}

    @IBAction func didTapView(_ sender: UITapGestureRecognizer) {}
}

// MARK: - Storyboardable
extension ItemsViewController: Storyboardable {}

// MARK: - ItemsViewModelViewDelegate
extension ItemsViewController: ItemsViewModelViewDelegate {
	func cellWidth() -> Double {
		switch currentViewLayoutState {
		case .horizontal: return Double(collectionView.frame.width)
		case .vertical: return Double(collectionView.frame.width / 2 - 15)
		}
	}
	
	func cellHeight() -> Double {
		switch currentViewLayoutState {
		case .horizontal: return Double(collectionView.frame.height / 1.5)
		case .vertical: return cellWidth()
		}
	}
}

// MARK: - UICollectionViewDataSource
extension ItemsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems(inSection: section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellViewModel = viewModel.cellViewModel(for: indexPath)
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellViewModel.identifier, for: indexPath)
		cellViewModel.commands[.configuration]?.perform(parameters: CommandParameters(cell: cell))
		return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ItemsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let cellViewModel = viewModel.cellViewModel(for: indexPath)
		didSelect(cellViewModel)
	}

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return viewModel.cellViewModel(for: indexPath).size
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateTopViews(forContentOffsetY: scrollView.contentOffset.y + view.safeAreaInsets.top)
    }
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let centerPoint = view.convert(view.center, to: collectionView)
		if let centerIndexPath = collectionView.indexPathForItem(at: centerPoint) {
			viewModel.didCenterCellViewModel(at: centerIndexPath)
		}
	}
}

// MARK: - SaladFoodItemCategory+ItemsViewLayoutStateSpecifier
extension SaladFoodItemCategory: ItemsViewLayoutStateSpecifier {
	var state: ItemsViewLayoutState {
		switch self {
		case .size, .lettuce: return .horizontal
		default: return .vertical
		}
	}
}
