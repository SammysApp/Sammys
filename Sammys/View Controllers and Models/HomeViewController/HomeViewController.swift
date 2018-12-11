//
//  HomeViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/10/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
	var viewModelParcel: HomeViewModelParcel? = HomeViewModelParcel(userState: .noUser)
		{ didSet { viewModel.parcel = viewModelParcel } }
	lazy var viewModel = HomeViewModel(parcel: viewModelParcel, viewDelegate: self)
	
	// MARK: - View Controllers
	lazy var purchasablesViewController = { PurchasablesViewController.storyboardInstance() }()
	lazy var builderViewController = { BuilderViewController.storyboardInstance() }()
	lazy var userViewController = { UserViewController.storyboardInstance().settingDelegate(to: self) }()
	lazy var bagViewController = { BagViewController.storyboardInstance().settingDelegate(to: self) }()
	
    // MARK: - IBOutlets
	@IBOutlet var collectionView: UICollectionView!
	@IBOutlet var collectionViewContainerView: UIView!
	
	@IBOutlet var favesButton: UIButton!
	
	@IBOutlet var bagButton: UIButton!
	@IBOutlet var bagButtonContainerView: UIView!
    @IBOutlet var bagQuantityLabel: UILabel!
	
	// MARK: - Property Overrides
    override var prefersStatusBarHidden: Bool { return false }
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    struct Constants {
		static let homeCollectionViewCellHeight: Double = 200
		static let collectionViewContentInset: CGFloat = 10
        static let collectionViewCornerRadius: CGFloat = 20
        static let collectionViewShadowOpacity: Float = 0.4
        static let bagButtonShadowOpacity: Float = 0.2
		static let favoritesTitle = "Favorites"
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupViews()
		
		viewModel.setupData()
			.get { self.collectionView.reloadData() }.catch { print($0) }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
	
	// MARK: - Setup
	func setupViews() {
		setupCollectionView()
		setupBagButton()
		setupBagButtonContainerView()
		setupCollectionViewContainerView()
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
	
    // MARK: - IBActions
    @IBAction func didTapAccount(_ sender: UIButton) {
		userViewController.viewModelParcel = UserViewModelParcel(userState: viewModel.userState)
		present(UINavigationController(rootViewController: userViewController), animated: true, completion: nil)
	}
    
    @IBAction func didTapFavorites(_ sender: UIButton) {
		guard case .currentUser(let user) = viewModel.userState else { return }
		purchasablesViewController.title = Constants.favoritesTitle
		purchasablesViewController.viewModelParcel = PurchasablesViewModelParcel(purchasables: viewModel.purchasableFavorites(for: user), layout: .categorized)
		present(UINavigationController(rootViewController: purchasablesViewController), animated: true, completion: nil)
	}
    
    @IBAction func didTapBag(_ sender: UIButton) {
		bagViewController.viewModelParcel = BagViewModelParcel(userState: viewModel.userState)
		present(UINavigationController(rootViewController: bagViewController), animated: true, completion: nil)
	}
	
	// MARK: - Debug
	func noCellViewModelMessage(for indexPath: IndexPath) -> String {
		return "No cell view model for index path, \(indexPath)."
	}
}

// MARK: - Storyboardable
extension HomeViewController: Storyboardable {}

// MARK: - HomeViewModelDelegate
extension HomeViewController: HomeViewModelViewDelegate {
	func cellWidth() -> Double {
		return Double(collectionView.bounds.width - (collectionView.contentInset.left + collectionView.contentInset.right))
	}
	
	func cellHeight() -> Double { return Constants.homeCollectionViewCellHeight }
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
		guard let cellViewModel = viewModel.cellViewModel(for: indexPath)
			else { fatalError(noCellViewModelMessage(for: indexPath)) }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellViewModel.identifier, for: indexPath)
        cellViewModel.commands[.configuration]?.perform(parameters: CollectionViewCellCommandParameters(cell: cell))
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		guard let cellViewModel = viewModel.cellViewModel(for: indexPath)
			else { fatalError(noCellViewModelMessage(for: indexPath)) }
		return CGSize(width: cellViewModel.width, height: cellViewModel.height)
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		viewModel.cellViewModel(for: indexPath)?.commands[.selection]?.perform(parameters: CollectionViewCellCommandParameters(cell: collectionView.cellForItem(at: indexPath), viewController: self))
	}
}

// MARK: - UserViewControllerDelegate
extension HomeViewController: UserViewControllerDelegate {
	// FIXME: Add method for logging out user.
}

// MARK: - BagViewControllerDelegate
extension HomeViewController: BagViewControllerDelegate {}

// MARK: - LoginPageViewControllerDelegate
extension HomeViewController: LoginPageViewControllerDelegate {
	func loginPageViewController(_ loginPageViewController: LoginPageViewController, didSignUp user: User) { viewModel.userState = .currentUser(user) }
	
	func loginPageViewController(_ loginPageViewController: LoginPageViewController, couldNotSignUpDueTo error: Error) { print(error) }
}

// MARK: - LoginViewControllerDelegate
extension HomeViewController: LoginViewControllerDelegate {
	func loginViewController(_ loginViewController: LoginViewController, didFinishLoggingIn user: User) { viewModel.userState = .currentUser(user) }
	
	func loginViewController(_ loginViewController: LoginViewController, couldNotLoginDueTo error: Error) {}
	
	func loginViewControllerDidTapSignUp(_ loginViewController: LoginViewController) {}
	
	func loginViewControllerDidCancel(_ loginViewController: LoginViewController) {}
}
