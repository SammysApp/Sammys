//
//  UICollectionViewCellViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/26/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

typealias UICollectionViewCellActionHandler = (UICollectionViewCellActionHandlerData) -> ()

struct UICollectionViewCellActionHandlerData {
    let cellViewModel: UICollectionViewCellViewModel?
    let indexPath: IndexPath?
    let cell: UICollectionViewCell?
    
    init(cellViewModel: UICollectionViewCellViewModel? = nil,
         indexPath: IndexPath? = nil,
         cell: UICollectionViewCell? = nil) {
        self.cellViewModel = cellViewModel
        self.indexPath = indexPath
        self.cell = cell
    }
}

enum UICollectionViewCellAction {
    case configuration
    case selection
}

protocol UICollectionViewCellViewModel {
    var identifier: String { get }
    var size: (width: Double, height: Double) { get }
    var isSelectable: Bool { get }
    var actions: [UICollectionViewCellAction: UICollectionViewCellActionHandler] { get }
}

extension UICollectionViewCellViewModel {
    var isSelectable: Bool { return true }
    var actions: [UICollectionViewCellAction: UICollectionViewCellActionHandler] { return [:] }
}

extension UICollectionViewCellViewModel {
    func perform(_ action: UICollectionViewCellAction, indexPath: IndexPath? = nil, cell: UICollectionViewCell? = nil) {
        self.actions[action]?(.init(cellViewModel: self, indexPath: indexPath, cell: cell))
    }
}
