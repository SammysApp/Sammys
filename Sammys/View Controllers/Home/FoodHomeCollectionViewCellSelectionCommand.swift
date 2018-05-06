//
//  FoodHomeCollectionViewCellSelectionCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/5/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct FoodHomeCollectionViewCellSelectionCommand: CollectionViewCellCommand {
    let didSelect: () -> Void
    
    func perform(parameters: CommandParameters) {
        didSelect()
    }
}
