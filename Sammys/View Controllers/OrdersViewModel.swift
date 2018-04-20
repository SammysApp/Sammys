//
//  OrdersViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/20/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class OrdersViewModel {
    var numberOfSections: Int {
        return 1
    }
    
    var numberOfRows: Int {
        return 1
    }
    
    func cellViewModels(for contextBounds: CGRect) -> [CollectionViewCellViewModel] {
        return [OrderCollectionViewCellViewModelFactory(size: CGSize(width: contextBounds.width - 20, height: 100)).create()]
    }
}
