//
//  OrdersViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/18/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class OrdersViewController: UIViewController, Storyboardable {
    typealias ViewController = OrdersViewController
    
    let viewModel = OrdersViewModel()
    
    // MARK: - IBOutlets
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.setData {
            self.collectionView.reloadData()
        }
    }
    
    func cellViewModel(for row: Int) -> CollectionViewCellViewModel {
        return viewModel.cellViewModels(for: view.bounds)[row]
    }
}

extension OrdersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = cellViewModel(for: indexPath.row)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: model.identifier, for: indexPath)
        model.commands[.configuration]?.perform(parameters: CommandParameters(cell: cell))
        return cell
    }
}

extension OrdersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let orderViewController = viewModel.orderViewController(for: indexPath)
        navigationController?.pushViewController(orderViewController, animated: true)
    }
}
