//
//  ItemCollectionViewCellSelectionCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/26/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct ItemCollectionViewCellSelectionCommand: CellCommand {
    private let item: Item
    
    init(item: Item) {
        self.item = item
    }
    
    func perform(cell: UICollectionViewCell?) {
        guard let cell = cell as? ItemCollectionViewCell else {
            return
        }
        
        print("selected \(item.name)")
    }
}
