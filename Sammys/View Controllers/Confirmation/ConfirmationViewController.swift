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
    var cellViewModels = [CollectionViewCellViewModel]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cellViewModels = viewModel.cellViewModels(for: view.bounds)
    }
    
    func cellViewModel(at row: Int) -> CollectionViewCellViewModel? {
        guard !cellViewModels.isEmpty && row < cellViewModels.count else { return nil }
        return cellViewModels[row]
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
        guard let cellViewModel = cellViewModel(at: indexPath.row)
            else { fatalError() }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellViewModel.identifier, for: indexPath)
        cellViewModel.commands[.configuration]?.perform(parameters: CommandParameters(cell: cell))
        return cell
    }
}

extension ConfirmationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cellViewModel(at: indexPath.row)?.commands[.selection]?.perform(parameters: CommandParameters(viewController: self))
    }
}
