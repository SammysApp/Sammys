//
//  HomeViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/10/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
	/// Must be set for use of the view model.
	var viewModelParcel: HomeViewModelParcel!
	{ didSet { viewModel = HomeViewModel(parcel: viewModelParcel, viewDelegate: self) } }
	var viewModel: HomeViewModel!
	
	// MARK: - View Controllers
	lazy var builderViewController: BuilderViewController = {
		let builderViewController = BuilderViewController.storyboardInstance()
		return builderViewController
	}()
	
	lazy var userViewController: UserViewController = {
		let userViewController = UserViewController.storyboardInstance()
		userViewController.delegate = self
		return userViewController
	}()
	
	lazy var bagViewController: BagViewController = {
		let bagViewController = BagViewController.storyboardInstance()
		return bagViewController
	}()
	
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
		static var homeCollectionViewCellHeight: Double = 200
		static var collectionViewContentInset: CGFloat = 10
        static var collectionViewCornerRadius: CGFloat = 20
        static var collectionViewShadowOpacity: Float = 0.4
        static var bagButtonShadowOpacity: Float = 0.2
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Set parcel here since first view controller.
		viewModelParcel = HomeViewModelParcel(userState: .noUser)
		
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
		setupBagButton()
		setupBagButtonContainerView()
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
    
    @IBAction func didTapFaves(_ sender: UIButton) {}
    
    @IBAction func didTapBag(_ sender: UIButton) {
		bagViewController.viewModelParcel = BagViewModelParcel(userState: viewModel.userState)
		present(UINavigationController(rootViewController: bagViewController), animated: true, completion: nil)
	}
	
	// MARK: - Debug
	func noCellViewModelMessage(for indexPath: IndexPath) -> String {
		return "No cell view model for index path, \(indexPath)"
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
extension HomeViewController: UserViewControllerDelegate {}

// MARK: - LoginViewControllerDelegate
extension HomeViewController: LoginViewControllerDelegate {
	func loginViewController(_ loginViewController: LoginViewController, didFinishLoggingIn user: User) { viewModel.userState = .currentUser(user) }
	
	func loginViewController(_ loginViewController: LoginViewController, couldNotLoginDueTo error: Error) {}
	
	func loginViewControllerDidTapSignUp(_ loginViewController: LoginViewController) {}
	
	func loginViewControllerDidCancel(_ loginViewController: LoginViewController) {}
}
