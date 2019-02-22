//
//  TableViewSection.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/2/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct TableViewSection {
    let title: String?
    let cellViewModels: [TableViewCellViewModel]
    
    init(title: String? = nil,
         cellViewModels: [TableViewCellViewModel]) {
        self.title = title
        self.cellViewModels = cellViewModels
    }
}
