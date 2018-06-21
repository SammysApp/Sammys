//
//  TableViewCellViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/29/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol TableViewCellViewModel {
    var identifier: String { get }
    var height: CGFloat { get }
    var isSelectable: Bool { get }
    var isEditable: Bool { get }
    var commands: [TableViewCommandActionKey: TableViewCellCommand] { get }
}

extension TableViewCellViewModel {
    var isSelectable: Bool {
        return true
    }
    
    var isEditable: Bool {
        return true
    }
}
