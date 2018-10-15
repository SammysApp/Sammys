//
//  HomeViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/10/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

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
	
    @IBOutlet var activityIndicatorView: NVActivityIndicatorView!
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    struct Constants {
        static var collectionViewCornerRadius: CGFloat = 20
        static var collectionViewShadowOpacity: Float = 0.4
        static var bagButtonShadowOpacity: Float = 0.2
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
		viewModel = HomeViewModel(delegate: self)
		
		setupCollectionView()
		setupCollectionViewContainerView()
		setupFavesButton()
		setupBagButton()
		setupBagButtonContainerView()
		setupActivityIndicatorView()
		setupNoFavesView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
	
	// MARK: - Setup
	func setupCollectionView() {
		collectionView.layer.cornerRadius = Constants.collectionViewCornerRadius
	}
	
	func setupCollectionViewContainerView() {
		collectionViewContainerView.add(UIView.Shadow(path: UIBezierPath(roundedRect: collectionView.bounds, cornerRadius: collectionView.layer.cornerRadius).cgPath, opacity: Constants.collectionViewShadowOpacity))
	}
	
	func setupBagButton() {
		bagButton.layer.masksToBounds = true
		bagButton.layer.cornerRadius = bagButton.bounds.width / 2
	}
	
	func setupBagButtonContainerView() {
		bagButtonContainerView.add(UIView.Shadow(path: UIBezierPath(roundedRect: bagButton.bounds, cornerRadius: bagButton.layer.cornerRadius).cgPath, opacity: Constants.bagButtonShadowOpacity))
	}
	
	func setupFavesButton() {
		viewModel.favesButtonImage.bindAndRun { self.favesButton.setBackgroundImage($0, for: .normal) }
	}
	
	func setupActivityIndicatorView() {
		activityIndicatorView.color = #colorLiteral(red: 0.3333333333, green: 0.3019607843, blue: 0.2745098039, alpha: 1)
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
    
    func presentLoginPageViewController() {
		present({
			let loginPageViewController = LoginPageViewController.storyboardInstance()
			//loginPageViewController.delegate = self
			return loginPageViewController
		}(), animated: true, completion: nil)
    }
	
	func didSelectItem(at indexPath: IndexPath) {
		switch viewModel.currentViewState.value {
		case .foods: navigationController?.pushViewController(ItemsViewController.storyboardInstance(), animated: true)
		case .faves: break
		}
	}
    
    // MARK: - IBActions
    @IBAction func didTapAccount(_ sender: UIButton) {
        present(UserViewController.storyboardInstance(), animated: true, completion: nil)
    }
    
    @IBAction func didTapFaves(_ sender: UIButton) {}
    
    @IBAction func didTapBag(_ sender: UIButton) {
        present(BagViewController.storyboardInstance(), animated: true, completion: nil)
    }
}

// MARK: - Storyboardable
extension HomeViewController: Storyboardable {}

// MARK: - HomeViewModelDelegate
extension HomeViewController: HomeViewModelDelegate {
	var contextBounds: CGSize {
		return collectionView.bounds.size
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
        cellViewModel.commands[.configuration]?.perform(parameters: CommandParameters(cell: cell))
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		didSelectItem(at: indexPath)
		viewModel.cellViewModel(for: indexPath).commands[.selection]?.perform(parameters: CommandParameters())
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return viewModel.cellViewModel(for: indexPath).size
	}
}
