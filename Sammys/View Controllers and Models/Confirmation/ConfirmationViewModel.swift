//
//  ConfirmationViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/13/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class ConfirmationViewModel {
    var order: Order?
    
    var numberOfSections: Int {
        return 1
    }
    
    var numberOfRows: Int {
        return cellViewModels(for: .zero).count
    }
    
    func cellViewModels(for contextBounds: CGRect) -> [CollectionViewCellViewModel] {
        guard let order = order else { fatalError() }
//        return [
//            MessageCollectionViewCellViewModelFactory(size: cellSize(for: contextBounds), order: order).create(),
//            MapCollectionViewCellViewModelFactory(size: cellSize(for: contextBounds)).create()
//        ]
		return []
    }
    
    func cellSize(for contextBounds: CGRect) -> CGSize {
        return CGSize(width: contextBounds.width - 20, height: 180)
    }
}