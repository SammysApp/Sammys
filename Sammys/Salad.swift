//
//  Salad.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

class Salad: Food {
    var size: Size?
    var lettuce: [Lettuce] = []
    var vegetables: [Vegetable] = []
    var extras: [Extra] = []
}

extension Salad {
    var price: Double {
        get {
            return size?.price ?? 0
        } set {}
    }
}
