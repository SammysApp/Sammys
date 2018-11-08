//
//  CollectionViewCellCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/22/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct CollectionViewCellCommandParameters {
    let cell: UICollectionViewCell?
    
    init(cell: UICollectionViewCell? = nil) {
        self.cell = cell
    }
}

protocol CollectionViewCellCommand {
    func perform(parameters: CollectionViewCellCommandParameters)
}

enum CollectionViewCommandActionKey {
    case configuration
    case selection
}
