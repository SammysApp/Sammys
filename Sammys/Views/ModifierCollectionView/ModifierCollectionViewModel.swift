//
//  ModifierCollectionViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/24/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol ModifierCollectionViewModelDelegate {
    func needsUpdate()
}

class ModifierCollectionViewModel {
    var delegate: ModifierCollectionViewModelDelegate?
    var modifiers: [Modifier]? {
        didSet {
            delegate?.needsUpdate()
        }
    }
    
    private struct Constants {
        static let cellSize = 140
        static let spacingSize = 10
    }
    
    var numberOfSections: Int {
        return 1
    }
    
    func numberOfItems(inSection section: Int) -> Int {
        return modifiers?.count ?? 0
    }
    
    func titleText(for indexPath: IndexPath) -> String {
        guard let modifiers = modifiers else { fatalError() }
        return modifiers[indexPath.row].title
    }
    
    func sizeForItem(at indexPath: IndexPath) -> CGSize {
        return CGSize(width: Constants.cellSize, height: Constants.cellSize)
    }
    
    func insetForSection(at section: Int, withContextBounds contextBounds: CGRect) -> UIEdgeInsets {
        let totalCellWidth = Constants.cellSize * numberOfItems(inSection: section)
        let totalSpacingWidth = Constants.spacingSize * (numberOfItems(inSection: section) - 1)
        
        let totalSum = CGFloat(totalCellWidth + totalSpacingWidth)
        let sidesInset = totalSum < contextBounds.width ? ((contextBounds.width - totalSum) / 2) : 10
        return UIEdgeInsets(top: 0, left: sidesInset, bottom: 0, right: sidesInset)
    }
}
