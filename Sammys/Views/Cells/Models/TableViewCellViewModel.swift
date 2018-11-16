//
//  TableViewCellViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/29/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol TableViewCellViewModel {
    var identifier: String { get }
    var height: Double { get }
    var isSelectable: Bool { get }
    var isEditable: Bool { get }
	var selectionHandler: (() -> Void)? { get }
    var commands: [TableViewCommandActionKey: TableViewCellCommand] { get }
}

extension TableViewCellViewModel {
    var isSelectable: Bool { return false }
    var isEditable: Bool { return false }
	var selectionHandler: (() -> Void)? { return nil }
}
