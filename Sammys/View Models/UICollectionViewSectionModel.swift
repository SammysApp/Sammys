//
//  UICollectionViewSectionModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/26/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

struct UICollectionViewSectionModel {
    let title: String?
    let cellViewModels: [UICollectionViewCellViewModel]
    
    init(title: String? = nil,
         cellViewModels: [UICollectionViewCellViewModel]) {
        self.title = title
        self.cellViewModels = cellViewModels
    }
}

extension Array where Element == UICollectionViewSectionModel {
    func cellViewModel(for indexPath: IndexPath) -> UICollectionViewCellViewModel {
        return self[indexPath.section].cellViewModels[indexPath.row]
    }
}
