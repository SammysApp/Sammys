//
//  CollectionViewCellViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/22/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct CollectionViewCellViewModel {
    let identifier: String
    let size: CGSize
    let commands: [CollectionViewCommandActionKey: CollectionViewCellCommand]
}
