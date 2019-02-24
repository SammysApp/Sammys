//
//  UITableViewSectionModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/2/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct UITableViewSectionModel {
    let title: String?
    let cellViewModels: [UITableViewCellViewModel]
    
    init(title: String? = nil,
         cellViewModels: [UITableViewCellViewModel]) {
        self.title = title
        self.cellViewModels = cellViewModels
    }
}

extension Array where Element == UITableViewSectionModel {
    func cellViewModel(for indexPath: IndexPath) -> UITableViewCellViewModel {
        return self[indexPath.section].cellViewModels[indexPath.row]
    }
}
