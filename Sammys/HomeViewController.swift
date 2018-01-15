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
    
    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func viewAccount(_ sender: UIButton) {
        let userViewController = UserViewController.storyboardInstance()
        present(userViewController, animated: true, completion: nil)
    }
    
    @IBAction func viewBag(_ sender: UIButton) {
        present(BagViewController.storyboardInstance(), animated: true, completion: nil)
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemsCell", for: indexPath) as! ItemsCollectionViewCell
        cell.itemsLabel.text = "Salads"
        cell.layer.cornerRadius = 20
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.pushViewController(ItemsViewController.storyboardInstance(), animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 20, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
