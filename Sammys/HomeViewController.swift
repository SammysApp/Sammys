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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func didTapAccount(_ sender: UIButton) {
        let userViewController = UserViewController.storyboardInstance()
        present(userViewController, animated: true, completion: nil)
    }
    
    @IBAction func didTapFaves(_ sender: UIButton) {
        viewModel.viewKey = .faves
        viewModel.getItems() {
            self.collectionView.reloadData()
        }
    }
    
    @IBAction func didTapBag(_ sender: UIButton) {
        present(BagViewController.storyboardInstance(), animated: true, completion: nil)
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = viewModel.item(for: indexPath)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.cellIdentifier.rawValue, for: indexPath) as! ItemsCollectionViewCell
        cell.itemsLabel.text = item.title
        cell.layer.cornerRadius = 20
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = viewModel.item(for: indexPath)
        if case .food = item.key {
            navigationController?.pushViewController(ItemsViewController.storyboardInstance(), animated: true)
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
