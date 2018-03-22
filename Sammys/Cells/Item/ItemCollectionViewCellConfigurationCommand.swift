//
//  ItemCollectionViewCellConfigurationCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/22/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class ItemCollectionViewCellConfigurationCommand: CellCommand {
    private let item: Item
    
    init(item: Item) {
        self.item = item
    }
    
    func perform(parameters: [CommandParameterKey : Any]?) {
        guard let cell = parameters?[.cell] as? ItemCollectionViewCell else {
            return
        }
        
        cell.titleLabel.text = item.name
        cell.backgroundColor = item.color
        
        StorageAPIClient.getItemImage(for: item) { result in
            switch result {
            case .success(let image):
                cell.imageView.image = image
            case .failure(_): break
            }
        }
    }
}
