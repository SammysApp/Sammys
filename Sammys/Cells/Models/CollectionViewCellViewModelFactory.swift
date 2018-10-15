//
//  CollectionViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/22/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol CollectionViewCellViewModelFactory {
    func create() -> CollectionViewCellViewModel
}
