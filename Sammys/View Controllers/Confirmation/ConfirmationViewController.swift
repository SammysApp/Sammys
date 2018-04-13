//
//  ConfirmationViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/12/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class ConfirmationViewController: UIViewController, Storyboardable {
    typealias ViewController = ConfirmationViewController
    
    let viewModel = ConfirmationViewModel()
    var cellViewModels = [CollectionViewCellViewModel]()
    
    // MARK: - IBOutlets
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cellViewModels = viewModel.cellViewModels(for: view.bounds)
    }
}

extension ConfirmationViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellViewModel = cellViewModels[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellViewModel.identifier, for: indexPath)
        cellViewModel.commands[.configuration]?.perform(cell: cell)
        return cell
    }
}

extension ConfirmationViewController: UICollectionViewDelegate {
    
}
