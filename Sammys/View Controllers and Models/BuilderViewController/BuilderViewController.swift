//
//  BuilderViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/4/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

enum BuilderViewLayoutState {
	case horizontal, vertical
}

protocol BuilderViewLayoutStateSpecifier {
	var state: BuilderViewLayoutState { get }
}

class BuilderViewController: UIViewController {
	typealias CellViewModel = BuilderViewModel.Section.CellViewModel
	
	/// Must be set for use by the view model.
	var viewModelParcel: BuilderViewModelParcel!
	private var viewModel: BuilderViewModel!
	
	let defaultViewLayoutState = BuilderViewLayoutState.horizontal
	let animatedCardCollectionViewLayout = AnimatedCollectionViewLayout()
	let flowCollectionViewLayout = UICollectionViewFlowLayout()
	let modifierViewEffect = UIBlurEffect(style: .dark)
	
	var currentViewLayoutState: BuilderViewLayoutState {
		guard let stateSpecifier = viewModel.itemCategory.value as? BuilderViewLayoutStateSpecifier else { return defaultViewLayoutState }
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

	// MARK: - Property Overrides
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
	
	struct Constants {
		static let collectionViewContentInset: CGFloat = 10
		
		static let cardAnimatorItemSpacing: CGFloat = 0.4
		static let cardAnimatorScaleRate: CGFloat = 0.75
		
		static let bottomButtonsCornerRadius: CGFloat = 10
		
		static let topViewsUpdateAnimationDuration = 0.25
	}

    // MARK: - Lifecycle
	override func viewDidLoad() {
        super.viewDidLoad()
		
		viewModel = BuilderViewModel(viewDelegate: self, parcel: viewModelParcel)
		
		setupViews()
		
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
	func setupViews() {
		setupCollectionView()
		setupAnimatedCardCollectionViewLayout()
		setupBackButton()
		setupNextButton()
	}
	
	func setupCollectionView() {
		collectionView.register(ItemCollectionViewCell.nib(), forCellWithReuseIdentifier: BuilderViewModel.ItemCellIdentifier.itemCell.rawValue)
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
	func updateCollectionView(for state: BuilderViewLayoutState) {
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
	func changeViewLayout(for state: BuilderViewLayoutState) {
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
	
	func didChangeItemCategory(with itemCategory: ItemCategory) {
		viewModel.setupData(for: itemCategory).catch { print($0) }
		itemCategoryLabel.text = itemCategory.name
		if let stateSpecifier = itemCategory as? BuilderViewLayoutStateSpecifier {
			changeViewLayout(for: stateSpecifier.state)
		} else { changeViewLayout(for: defaultViewLayoutState) }
	}
	
	func didCenter(at cellViewModel: CellViewModel) {
		itemNameLabel.text = cellViewModel.foodItem.name
		if let pricedFoodItem = cellViewModel.foodItem as? PricedItem {
			itemPriceLabel.text = "\(pricedFoodItem.price)"
		}
	}
	
	func didSelect(_ cellViewModel: CellViewModel) {
		do { try viewModel.toggle(cellViewModel.foodItem) }
		catch { print(error) }
	}
	
	func presentAddFoodViewController() throws {
		let addFoodViewController = AddBagViewController.storyboardInstance()
		addFoodViewController.viewModelParcel = try viewModel.addFoodViewModelParcel()
		addFoodViewController.delegate = self
		present(UINavigationController(rootViewController: addFoodViewController), animated: true, completion: nil)
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
extension BuilderViewController: Storyboardable {}

// MARK: - BuilderViewModelViewDelegate
extension BuilderViewController: BuilderViewModelViewDelegate {
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
extension BuilderViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems(inSection: section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellViewModel = viewModel.cellViewModel(for: indexPath)
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellViewModel.identifier, for: indexPath)
		cellViewModel.commands[.configuration]?.perform(parameters: CollectionViewCellCommandParameters(cell: cell))
		return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension BuilderViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let cellViewModel = viewModel.cellViewModel(for: indexPath)
		didSelect(cellViewModel)
	}

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let cellViewModel = viewModel.cellViewModel(for: indexPath)
		return CGSize(width: cellViewModel.width, height: cellViewModel.height)
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

// MARK: - AddBagViewControllerDelegate
extension BuilderViewController: AddBagViewControllerDelegate {
	func addBagViewController(_ addBagViewController: AddBagViewController, didAddItemedPurchasable itemedPurchasable: ItemedPurchasable) {
		addBagViewController.dismiss(animated: true) {
			self.navigationController?.popViewController(animated: true)
		}
	}
}

// MARK: - ItemsViewControllerDelegate
extension BuilderViewController: ItemsViewControllerDelegate {
	func itemsViewController(_ itemsViewController: ItemsViewController, didSelectEdit itemCategory: ItemCategory, in itemedPurchasable: ItemedPurchasable) {
		itemsViewController.dismiss(animated: true, completion: nil)
		viewModel.set(to: itemCategory)
	}
}

// MARK: - SaladItemCategory+BuilderViewLayoutStateSpecifier
extension SaladItemCategory: BuilderViewLayoutStateSpecifier {
	var state: BuilderViewLayoutState {
		switch self {
		case .size, .lettuce: return .horizontal
		default: return .vertical
		}
	}
}
