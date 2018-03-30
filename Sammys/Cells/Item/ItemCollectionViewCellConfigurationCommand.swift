//
//  ItemCollectionViewCellConfigurationCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/22/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct ItemCollectionViewCellConfigurationCommand: CollectionViewCellCommand {
    private let item: Item
    
    private struct Constants {
        static let cornerRadius: CGFloat = 20
    }
    
    init(item: Item) {
        self.item = item
    }
    
    func perform(cell: UICollectionViewCell?) {
        guard let cell = cell as? ItemCollectionViewCell else {
            return
        }
        
        cell.layer.cornerRadius = Constants.cornerRadius
        cell.backgroundColor = item.color
        
        cell.titleLabel.text = item.name
        if let saladItemType = type(of: item).type as? SaladItemType,
            saladItemType == .size || saladItemType == .lettuce {
            cell.titleLabel.text = nil
        }
        
        cell.imageView.image = nil
        StorageAPIClient.getItemImage(for: item) { result in
            switch result {
            case .success(let image):
                cell.imageView.image = image
            case .failure(_): break
            }
        }
    }
}
