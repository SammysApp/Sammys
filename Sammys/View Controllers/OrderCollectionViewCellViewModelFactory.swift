//
//  OrderCollectionViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/20/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

enum OrderCellIdentifier: String {
    case orderCell
}

struct OrderCollectionViewCellViewModelFactory: CollectionViewCellViewModelFactory {
    let size: CGSize
    
    init(size: CGSize) {
        self.size = size
    }
    
    func create() -> CollectionViewCellViewModel {
        return CollectionViewCellViewModel(identifier: OrderCellIdentifier.orderCell.rawValue, size: size, commands: [.configuration: OrderCollectionViewCellConfigurationCommand()])
    }
}
