//
//  BuilderViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/4/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol BuilderViewControllerDelegate {
	/// Shows `AddBagViewController` by default.
	func builderViewController(_ builderViewController: BuilderViewController, didFinishBuilding itemedPurchasable: ItemedPurchasable)
}

enum BuilderViewLayoutState {
	case horizontal, vertical
}

protocol BuilderViewLayoutStateSpecifier {
	var state: BuilderViewLayoutState { get }
}

class BuilderViewController: UIViewController {
	/// Must be set for use of the view model.
	var viewModelParcel: BuilderViewModelParcel!
	{ didSet { viewModel = BuilderViewModel(parcel: viewModelParcel, viewDelegate: self) } }
	var viewModel: BuilderViewModel! { didSet { loadViews() } }
	
	var delegate: BuilderViewControllerDelegate?
	
	var currentViewLayoutState = BuilderViewLayoutState.horizontal
	{ didSet { changeViewLayout(for: currentViewLayoutState) } }
	
	let animatedCardCollectionViewLayout = AnimatedCollectionViewLayout()
	let flowCollectionViewLayout = UICollectionViewFlowLayout()
	
	// MARK: - View Controllers
	lazy var addBagViewController = { AddBagViewController.storyboardInstance().settingDelegate(to: self) }()

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

	// MARK: - Property Overrides
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
	
	struct Constants {
		static let collectionViewContentInset: CGFloat = 10
		static let collectionViewNumberOfItemsPerRow = 2
		
		static let cardAnimatorItemSpacing: CGFloat = 0.4
		static let cardAnimatorScaleRate: CGFloat = 0.75
		
		static let bottomButtonsCornerRadius: CGFloat = 10
		
		static let topViewsUpdateAnimationDuration = 0.25
	}

    // MARK: - Lifecycle
	override func viewDidLoad() {
        super.viewDidLoad()
		
		setupViews()
		handleUpdatedItemCategory(viewModel.currentItemCategory)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: true)
    }
	
	// MARK: - Setup
	func loadViews() {
		collectionView?.reloadData()
	}
	
	func setupViews() {
		setupCollectionView()
		setupAnimatedCardCollectionViewLayout()
		setupBackButton()
		setupNextButton()
		loadViews()
	}
	
	func setupCollectionView() {
		collectionView.register(ItemCollectionViewCell.nib(), forCellWithReuseIdentifier: BuilderCellIdentifier.itemCell.rawValue)
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
	
	func handleUpdatedItemCategory(_ itemCategory: ItemCategory) {
		viewModel.setupData(for: itemCategory).get { self.loadViews() }.catch { print($0) }
		itemCategoryLabel.text = itemCategory.name
		if let stateSpecifier = itemCategory as? BuilderViewLayoutStateSpecifier {
			currentViewLayoutState = stateSpecifier.state
		}
	}
	
	func handleCenter(at cellViewModel: BuilderViewModel.Section.CellViewModel) {
		itemNameLabel.text = cellViewModel.item.name
		if let pricedItem = cellViewModel.item as? PricedItem {
			itemPriceLabel.text = pricedItem.price.priceString
		}
	}
	
	func set(to itemCategory: ItemCategory) {
		viewModel.set(itemCategory)
		handleUpdatedItemCategory(viewModel.currentItemCategory)
	}
	
	func presentAddBagViewController(with itemedPurchasable: ItemedPurchasable) {
		addBagViewController.viewModelParcel = AddBagViewModelParcel(itemedPurchasable: itemedPurchasable)
		present(UINavigationController(rootViewController: addBagViewController), animated: true, completion: nil)
	}

    // MARK: - IBActions
    @IBAction func didTapNext(_ sender: UIButton) {
		do {
			if viewModel.isAtLastItemCategory {
				let itemedPurchasable = try viewModel.build()
				if delegate == nil { presentAddBagViewController(with: itemedPurchasable) }
				else { delegate?.builderViewController(self, didFinishBuilding: itemedPurchasable) }
			} else {
				try viewModel.incrementItemCategory()
				handleUpdatedItemCategory(viewModel.currentItemCategory)
			}
		} catch { print(error) }
    }

    @IBAction func didTapBack(_ sender: UIButton) {
		do {
			try viewModel.decrementItemCategory()
			handleUpdatedItemCategory(viewModel.currentItemCategory)
		} catch { print(error) }
    }

    @IBAction func didTapFinish(_ sender: UIButton) {}
	
	// MARK: - Debug
	func noCellViewModelMessage(for indexPath: IndexPath) -> String {
		return "No cell view model for index path, \(indexPath)."
	}
}

// MARK: - Delegatable
extension BuilderViewController: Delegatable {}

// MARK: - Storyboardable
extension BuilderViewController: Storyboardable {}

// MARK: - BuilderViewModelViewDelegate
extension BuilderViewController: BuilderViewModelViewDelegate {
	func cellWidth() -> Double {
		switch currentViewLayoutState {
		case .horizontal: return Double(collectionView.frame.width)
		case .vertical:
			let totalCellsWidth = collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right)
			guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return Double(totalCellsWidth) / Double(Constants.collectionViewNumberOfItemsPerRow) }
			return Double(totalCellsWidth - (layout.minimumInteritemSpacing * CGFloat(Constants.collectionViewNumberOfItemsPerRow - 1))) / Double(Constants.collectionViewNumberOfItemsPerRow)
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
		guard let cellViewModel = viewModel.cellViewModel(for: indexPath)
			else { fatalError(noCellViewModelMessage(for: indexPath)) }
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellViewModel.identifier, for: indexPath)
		cellViewModel.commands[.configuration]?.perform(parameters: CollectionViewCellCommandParameters(cell: cell))
		return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension BuilderViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		guard let cellViewModel = viewModel.cellViewModel(for: indexPath)
			else { fatalError(noCellViewModelMessage(for: indexPath)) }
		return CGSize(width: cellViewModel.width, height: cellViewModel.height)
    }
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		viewModel.cellViewModel(for: indexPath)?.commands[.selection]?.perform(parameters: CollectionViewCellCommandParameters(cell: collectionView.cellForItem(at: indexPath), viewController: self))
	}
}

// MARK: - UIScrollViewDelegate
extension BuilderViewController: UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		updateTopViews(forContentOffsetY: scrollView.contentOffset.y + view.safeAreaInsets.top)
	}
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let centerPoint = view.convert(view.center, to: collectionView)
		if let centerIndexPath = collectionView.indexPathForItem(at: centerPoint),
			let cellViewModel = viewModel.cellViewModel(for: centerIndexPath) {
			handleCenter(at: cellViewModel)
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
	
	func addBagViewControllerDidCancel(_ addBagViewController: AddBagViewController) {}
}

// MARK: - ItemsViewControllerDelegate
extension BuilderViewController: ItemsViewControllerDelegate {
	func itemsViewController(_ itemsViewController: ItemsViewController, didSelectEdit itemCategory: ItemCategory, in itemedPurchasable: ItemedPurchasable) {
		itemsViewController.dismiss(animated: true, completion: nil)
		set(to: itemCategory)
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

extension BuilderViewControllerDelegate {
	func builderViewController(_ builderViewController: BuilderViewController, didFinishBuilding itemedPurchasable: ItemedPurchasable) {
		builderViewController.presentAddBagViewController(with: itemedPurchasable)
	}
}
