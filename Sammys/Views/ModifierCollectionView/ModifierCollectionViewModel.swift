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
    var item: Item? {
        didSet {
            delegate?.needsUpdate()
        }
    }
    var modifiers: [Modifier]? {
        return item?.modifiers
    }
    var didSelect: ((Modifier, Item) -> Void)?
    var shouldShowSelected: ((Modifier, Item) -> Bool)?
    
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
    
    func backgroundColor(for indexPath: IndexPath) -> UIColor {
        guard let item = item, let modifiers = modifiers else { fatalError() }
        return (shouldShowSelected?(modifiers[indexPath.row], item) ?? false) ? .white : #colorLiteral(red: 0.3333333333, green: 0.3019607843, blue: 0.2745098039, alpha: 1)
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
    
    func selectItem(at indexPath: IndexPath) {
        guard let modifiers = modifiers, let item = item else { return }
        didSelect?(modifiers[indexPath.row], item)
    }
}
