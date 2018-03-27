//
//  ItemsViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/22/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class ItemsViewModel {
    let data = FoodsDataStore.shared.foodsData!
    
    var numberOfSections: Int {
        return 1
    }
    
    func numberOfItems(for itemType: SaladItemType) -> Int {
        return items(for: itemType)?.count ?? 0
    }
    
    func cellViewModels(for itemType: SaladItemType, contextBounds: CGRect) -> [CellViewModel] {
        if let items = items(for: itemType) {
            let size = cellSize(for: itemType, contextBounds: contextBounds)
            return items.map { ItemCollectionViewCellViewModelFactory(item: $0, size: size).create() }
        }
        return []
    }
    
    func cellSize(for itemType: SaladItemType, contextBounds: CGRect) -> CGSize {
        switch itemType {
        case .vegetable, .topping, .dressing:
            let size = (contextBounds.width/2) - 15
            return CGSize(width: size, height: size)
        default:
            return CGSize(width: contextBounds.width, height: contextBounds.height/1.5)
        }
    }
    
    func items(for itemType: SaladItemType) -> [Item]? {
        return data.salad.allItems[itemType]
    }
}
