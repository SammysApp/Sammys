//
//  HomeViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/10/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, Storyboardable {
    typealias ViewController = HomeViewController
    
    let viewModel = HomeViewModel()
    
    // MARK: - IBOutlets
    @IBOutlet var collectionView: UICollectionView!
    
    private struct Constants {
        static let cellCornerRadius: CGFloat = 20
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - IBActions
    @IBAction func didTapAccount(_ sender: UIButton) {
        let userViewController = UserViewController.storyboardInstance()
        present(userViewController, animated: true, completion: nil)
    }
    
    @IBAction func didTapFaves(_ sender: UIButton) {
        viewModel.toggleFaves()
        viewModel.getItems() {
            self.collectionView.reloadData()
        }
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
        let item = viewModel.item(for: indexPath)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.cellIdentifier.rawValue, for: indexPath) as! ItemsCollectionViewCell
        cell.itemsLabel.text = item.title
        cell.layer.cornerRadius = Constants.cellCornerRadius
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = viewModel.item(for: indexPath)
        if item.key == .food {
            navigationController?.pushViewController(ItemsViewController.storyboardInstance(), animated: true)
        } else if item.key == .fave {
            let faveItem = item as! FaveHomeItem
            let foodViewController = FoodViewController()
            foodViewController.food = faveItem.food
            foodViewController.didGoBack = { foodViewController in
                self.viewModel.setFavorite(faveItem.food)
                self.collectionView.reloadData()
            }
            navigationController?.pushViewController(foodViewController, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = viewModel.item(for: indexPath)
        switch item.key {
        case .food:
            return CGSize(width: collectionView.frame.width - 20, height: 200)
        case .fave:
            let size = (collectionView.frame.width / 2) - 15
            return CGSize(width: size, height: size)
        }
    }
}

// MARK: - View Model Delegate
extension HomeViewController: HomeViewModelDelegate {
    var favoritesDidChange: () -> Void {
        return { self.collectionView.reloadData() }
    }
}
