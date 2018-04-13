//
//  ConfirmationViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/13/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class ConfirmationViewModel {
    var numberOfSections: Int {
        return 1
    }
    
    var numberOfRows: Int {
        return 1
    }
    
    func cellViewModels(for contextBounds: CGRect) -> [CollectionViewCellViewModel] {
        return [
            MapCollectionViewCellViewModelFactory(size: CGSize(width: contextBounds.width - 20, height: 180)).create()
        ]
    }
}
