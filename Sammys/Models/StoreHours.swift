//
//  StoreHours.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/4/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

struct StoreHours: Codable {
    let openingDate: Date
    let closingDate: Date
    let isOpen: Bool
}
