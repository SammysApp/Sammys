//
//  UITableViewCellViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/29/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

typealias UITableViewCellActionHandler = (UITableViewCellActionHandlerData) -> ()

struct UITableViewCellActionHandlerData {
    let cellViewModel: UITableViewCellViewModel?
    let indexPath: IndexPath?
    let cell: UITableViewCell?
    
    init(cellViewModel: UITableViewCellViewModel? = nil,
        indexPath: IndexPath? = nil,
        cell: UITableViewCell? = nil) {
        self.cellViewModel = cellViewModel
        self.indexPath = indexPath
        self.cell = cell
    }
}

enum UITableViewCellAction {
    case configuration
    case selection
}

protocol UITableViewCellViewModel {
    var identifier: String { get }
    var height: Double { get }
    var isSelectable: Bool { get }
    var actions: [UITableViewCellAction: UITableViewCellActionHandler] { get }
}

extension UITableViewCellViewModel {
    var isSelectable: Bool { return true }
    var actions: [UITableViewCellAction: UITableViewCellActionHandler] { return [:] }
}

extension UITableViewCellViewModel {
    func perform(_ action: UITableViewCellAction, indexPath: IndexPath? = nil, cell: UITableViewCell? = nil) {
        self.actions[action]?(.init(cellViewModel: self, indexPath: indexPath, cell: cell))
    }
}
