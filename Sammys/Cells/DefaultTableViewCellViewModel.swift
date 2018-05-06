//
//  DefaultTableViewCellViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/4/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct DefaultTableViewCellViewModel: TableViewCellViewModel {
    let identifier: String
    let height: CGFloat
    let commands: [TableViewCommandActionKey : TableViewCellCommand]
}
