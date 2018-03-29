//
//  CellViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/22/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct CellViewModel {
    let identifier: String
    let size: CGSize
    let commands: [CommandActionKey: CellCommand]
}
