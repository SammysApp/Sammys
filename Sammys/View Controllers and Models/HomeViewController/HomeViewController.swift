//
//  HomeViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/10/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    var viewModel: HomeViewModel!
	
    // MARK: - IBOutlets
	@IBOutlet var collectionView: UICollectionView!
	@IBOutlet var collectionViewContainerView: UIView!
	
	@IBOutlet var favesButton: UIButton!
	
	@IBOutlet var bagButton: UIButton!
	@IBOutlet var bagButtonContainerView: UIView!
    @IBOutlet var bagQuantityLabel: UILabel!
	
	@IBOutlet var noFavesView: UIView!
	
	// MARK: - Property Overrides
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    struct Constants {
		static var homeCollectionViewCellHeight: Double = 200
		static var collectionViewContentInset: CGFloat = 10
        static var collectionViewCornerRadius: CGFloat = 20
        static var collectionViewShadowOpacity: Float = 0.4
        static var bagButtonShadowOpacity: Float = 0.2
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
		viewModel = HomeViewModel(self)
		
		setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// Run once correct collection view size.
		setupCollectionViewContainerView()
		collectionView.reloadData()
	}
	
	// MARK: - Setup
	func setupViews() {
		setupCollectionView()
		setupFavesButton()
		setupBagButton()
		setupBagButtonContainerView()
		setupNoFavesView()
	}
	
	func setupCollectionView() {
		collectionView.layer.cornerRadius = Constants.collectionViewCornerRadius
		collectionView.contentInset = UIEdgeInsets(
			top: Constants.collectionViewContentInset,
			left: Constants.collectionViewContentInset,
			bottom: 0,
			right: Constants.collectionViewContentInset
		)
	}
	
	func setupCollectionViewContainerView() {
		collectionViewContainerView.add(
			UIView.Shadow(
				path: UIBezierPath(roundedRect: collectionView.frame, cornerRadius: collectionView.layer.cornerRadius).cgPath,
				opacity: Constants.collectionViewShadowOpacity
			)
		)
	}
	
	func setupBagButton() {
		bagButton.layer.masksToBounds = true
		bagButton.layer.cornerRadius = bagButton.bounds.width / 2
	}
	
	func setupBagButtonContainerView() {
		bagButtonContainerView.add(
			UIView.Shadow(
				path: UIBezierPath(roundedRect: bagButton.bounds, cornerRadius: bagButton.layer.cornerRadius).cgPath,
				opacity: Constants.bagButtonShadowOpacity
			)
		)
	}
	
	func setupFavesButton() {
		viewModel.favesButtonImage.bindAndRun { self.favesButton.setBackgroundImage($0.image, for: .normal) }
	}
    
    func setupNoFavesView() {
		// Insert as subview under the bag button so can use the button still.
        view.insertSubview(noFavesView, belowSubview: bagButtonContainerView)
		
        noFavesView.layer.cornerRadius = Constants.collectionViewCornerRadius
        noFavesView.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        noFavesView.translatesAutoresizingMaskIntoConstraints = false
		
        [noFavesView.leftAnchor.constraint(equalTo: collectionView.leftAnchor),
		noFavesView.topAnchor.constraint(equalTo: collectionView.topAnchor),
		noFavesView.rightAnchor.constraint(equalTo: collectionView.rightAnchor),
		noFavesView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor)
		].forEach { $0.isActive = true }
		
		viewModel.shouldHideNoFavesView.bindAndRun { self.noFavesView.isHidden = $0 }
    }
	
	// MARK: - Methods
    func didSelectItem(at indexPath: IndexPath) {
		switch viewModel.currentViewState.value {
		case .home:
			guard let viewModelParcel = viewModel.itemsViewModelParcel(for: indexPath) else { return }
			let itemsViewController = BuilderViewController.storyboardInstance()
			itemsViewController.viewModelParcel = viewModelParcel
			navigationController?.pushViewController(itemsViewController, animated: true)
		case .faves: break
		}
	}
    
    // MARK: - IBActions
    @IBAction func didTapAccount(_ sender: UIButton) {}
    
    @IBAction func didTapFaves(_ sender: UIButton) {}
    
    @IBAction func didTapBag(_ sender: UIButton) {
		present(UINavigationController(rootViewController: BagViewController.storyboardInstance()), animated: true, completion: nil)
	}
}

// MARK: - Storyboardable
extension HomeViewController: Storyboardable {}

// MARK: - HomeViewModelDelegate
extension HomeViewController: HomeViewModelViewDelegate {
	func cellWidth(for state: HomeViewState) -> Double {
		switch state {
		case .home: return Double(collectionView.bounds.width - (collectionView.contentInset.left + collectionView.contentInset.right))
		case .faves: return 0
		}
	}
	
	func cellHeight(for state: HomeViewState) -> Double {
		switch state {
		case .home: return Constants.homeCollectionViewCellHeight
		case .faves: return 0
		}
	}
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellViewModel = viewModel.cellViewModel(for: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellViewModel.identifier, for: indexPath)
        cellViewModel.commands[.configuration]?.perform(parameters: CollectionViewCellCommandParameters(cell: cell))
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		didSelectItem(at: indexPath)
		viewModel.cellViewModel(for: indexPath).commands[.selection]?.perform(parameters: CollectionViewCellCommandParameters())
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let cellViewModel = viewModel.cellViewModel(for: indexPath)
		return CGSize(width: cellViewModel.width, height: cellViewModel.height)
	}
}

enum HomeImage {
	case home, heart
	
	var image: UIImage {
		switch self {
		case .home: return #imageLiteral(resourceName: "Home.pdf")
		case .heart: return #imageLiteral(resourceName: "Heart.pdf")
		}
	}
}
