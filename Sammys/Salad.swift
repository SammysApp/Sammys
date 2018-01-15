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
    
    var itemDictionary: ItemsDictionary {
        var dictionary: ItemsDictionary = [:]
        guard let size = size else {
            return dictionary
        }
        dictionary[0] = ("Salad", [size])
        dictionary[1] = ("Lettuce", lettuce)
        dictionary[2] = ("Vegetables", vegetables)
        if !extras.isEmpty {
            dictionary[3] = ("Extras", extras)
        }
        return dictionary
    }
}
