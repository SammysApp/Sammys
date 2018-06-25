//
//  HomeViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/10/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

/// The home 🏠 of the app. Includes foods and user's favorites.
class HomeViewController: UIViewController, Storyboardable {
    typealias ViewController = HomeViewController
    
    var viewModel: HomeViewModel!
    
    // MARK: - IBOutlets
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewContainerView: UIView!
    @IBOutlet var favesButton: UIButton!
    @IBOutlet var bagButton: UIButton!
    @IBOutlet var bagButtonContainerView: UIView!
    @IBOutlet var bagQuantityLabel: UILabel!
    @IBOutlet var noFavesView: UIView!
    @IBOutlet var activityIndicatorView: NVActivityIndicatorView! {
        didSet {
            activityIndicatorView.color = #colorLiteral(red: 0.3333333333, green: 0.3019607843, blue: 0.2745098039, alpha: 1)
        }
    }
    
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
        
        viewModel = HomeViewModel(contextBounds: collectionView.bounds, self)
        setupNoFavesView()
        noFavesView.isHidden = true
        
        collectionView.layer.cornerRadius = Constants.collectionViewCornerRadius
        collectionViewContainerView.add(UIView.Shadow(path: UIBezierPath(roundedRect: collectionView.bounds, cornerRadius: collectionView.layer.cornerRadius).cgPath, opacity: Constants.collectionViewShadowOpacity))
        
        bagButton.layer.masksToBounds = true
        bagButton.layer.cornerRadius = bagButton.bounds.width / 2
        bagButtonContainerView.add(UIView.Shadow(path: UIBezierPath(roundedRect: bagButton.bounds, cornerRadius: bagButton.layer.cornerRadius).cgPath, opacity: Constants.bagButtonShadowOpacity))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        if viewModel.needsBagQuantityUpdate {
            bagQuantityLabel.text = viewModel.bagQuantityLabelText
        }
    }
    
    func setupNoFavesView() {
        view.insertSubview(noFavesView, belowSubview: bagButtonContainerView)
        noFavesView.layer.cornerRadius = Constants.collectionViewCornerRadius
        noFavesView.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        noFavesView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noFavesView.leftAnchor.constraint(equalTo: collectionView.leftAnchor),
            noFavesView.topAnchor.constraint(equalTo: collectionView.topAnchor),
            noFavesView.rightAnchor.constraint(equalTo: collectionView.rightAnchor),
            noFavesView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor)
        ])
    }
    
    func updateFavesButton() {
        favesButton.setBackgroundImage(viewModel.favesButtonImage, for: .normal)
    }
    
    func updateNoFavesViewIsHidden() {
        if viewModel.viewKey == .faves && viewModel.isNoItems {
            noFavesView.isHidden = false
        } else {
            noFavesView.isHidden = true
        }
    }
    
    func pushAddViewController(with food: Food) {
        guard let addViewController = AddViewController.storyboardInstance() as? AddViewController else { return }
        addViewController.viewModel = AddViewModel(food: food)
        addViewController.viewModel.shouldUnfave = true
        addViewController.viewModel.didGoBack = { addViewController, food in
            // Override favorite with any new additions to the food.
            if let food = food { self.viewModel.setFavorite(food) }
            self.collectionView.reloadData()
        }
        navigationController?.pushViewController(addViewController, animated: true)
    }
    
    func presentLoginPageViewController() {
        let loginPageViewController = LoginPageViewController.storyboardInstance() as! LoginPageViewController
        loginPageViewController.delegate = self
        present(loginPageViewController, animated: true, completion: nil)
    }
    
    // MARK: - IBActions
    @IBAction func didTapAccount(_ sender: UIButton) {
        present(UserViewController.storyboardInstance(), animated: true, completion: nil)
    }
    
    @IBAction func didTapFaves(_ sender: UIButton) {
        viewModel.toggleFavesView()
    }
    
    @IBAction func didTapBag(_ sender: UIButton) {
        present(BagViewController.storyboardInstance(), animated: true, completion: nil)
    }
}

// MARK: - Collection View Data Source & Delegate
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.cellViewModel(for: indexPath).commands[.selection]?.perform(parameters: CommandParameters())
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel.cellViewModel(for: indexPath).size
    }
}

// MARK: - View Model Delegate
extension HomeViewController: HomeViewModelDelegate {
    var collectionViewDataDidChange: () -> Void {
        return {
            self.collectionView.reloadData()
            self.updateNoFavesViewIsHidden()
            self.updateFavesButton()
        }
    }
    
    var didSelectFood: () -> Void {
        return {
            self.navigationController?.pushViewController(ItemsViewController.storyboardInstance(), animated: true)
        }
    }
    
    var didSelectFavorite: (Food) -> Void {
        return {
            self.pushAddViewController(with: $0)
        }
    }
    
    func didStartLoading() {
        activityIndicatorView.startAnimating()
    }
    
    func didStopLoading() {
        activityIndicatorView.stopAnimating()
    }
    
    func showLogin() {
        presentLoginPageViewController()
    }
}

extension HomeViewController: LoginPageViewControllerDelegate {
    func loginPageViewControllerDidCancel(_ loginPageViewController: LoginPageViewController) {
        
    }
    
    func loginPageViewControllerDidLogin(_ loginPageViewController: LoginPageViewController) {
        viewModel.toggleFavesView()
    }
}
