//
//  QuantityCollectionViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/22/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

enum Quantity {
    case none
    case some(Int)
}

class QuantityCollectionViewModel {
    let textColor: UIColor
    let backgroundColor: UIColor
    let deleteBackgroundColor: UIColor
    private let didSelectQuantity: ((Quantity) -> Void)?
    
    init(textColor: UIColor = .black, backgroundColor: UIColor = .white, deleteBackgroundColor: UIColor = .red, deleteImage: UIImage? = nil, didSelectQuantity: ((Quantity) -> Void)? = nil) {
        self.didSelectQuantity = didSelectQuantity
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.deleteBackgroundColor = deleteBackgroundColor
    }
    
    var numberOfSections: Int {
        return 1
    }
    
    func numberOfItems(inSection section: Int) -> Int {
        return 10
    }
    
    func indexPathShouldShowDelete(_ indexPath: IndexPath) -> Bool {
        return indexPath.row == 0
    }
    
    func didSelectItem(at indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            didSelectQuantity?(.none)
        default:
            didSelectQuantity?(.some(indexPath.row))
        }
    }
}
