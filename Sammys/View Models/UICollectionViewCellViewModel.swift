//
//  UICollectionViewCellViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/26/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

typealias UICollectionViewCellSizeHandler = (UICollectionViewCellSizeHandlerData) -> UICollectionViewCellViewModelSize
typealias UICollectionViewCellActionHandler = (UICollectionViewCellActionHandlerData) -> ()

protocol UICollectionViewCellViewModel {
    var identifier: String { get }
    var size: UICollectionViewCellViewModelSize { get }
    var sizeHandler: UICollectionViewCellSizeHandler? { get }
    var isSelectable: Bool { get }
    var actions: [UICollectionViewCellAction: UICollectionViewCellActionHandler] { get }
}

struct UICollectionViewCellViewModelSize {
    let width: Double
    let height: Double
    
    static var zero: UICollectionViewCellViewModelSize { return .init(width: 0, height: 0) }
}

struct UICollectionViewCellSizeHandlerData {
    let cellViewModel: UICollectionViewCellViewModel
    let indexPath: IndexPath
}

enum UICollectionViewCellAction {
    case configuration
    case selection
}

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

extension UICollectionViewCellViewModel {
    var size: UICollectionViewCellViewModelSize { return .zero }
    var sizeHandler: UICollectionViewCellSizeHandler? { return nil }
    var isSelectable: Bool { return true }
    var actions: [UICollectionViewCellAction: UICollectionViewCellActionHandler] { return [:] }
}

extension UICollectionViewCellViewModel {
    func perform(_ action: UICollectionViewCellAction, indexPath: IndexPath? = nil, cell: UICollectionViewCell? = nil) {
        self.actions[action]?(.init(cellViewModel: self, indexPath: indexPath, cell: cell))
    }
}
