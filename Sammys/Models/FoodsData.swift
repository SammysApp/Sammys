//
//  FoodsData.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/25/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

/// A type representing all available foods.
struct FoodsData: Decodable {
    let salad: SaladData
    
    struct SaladData: Decodable {
        let sizes: [Size]
        let lettuce: [Lettuce]
        let vegetables: [Vegetable]
        let toppings: [Topping]
        let dressings: [Dressing]
        let extras: [Extra]
        
        var allItems: [SaladItemType : [Item]] {
            return [
                .size: sizes,
                .lettuce: lettuce,
                .vegetable: vegetables,
                .topping: toppings,
                .dressing: dressings,
                .extra: extras
            ]
        }
    }
}
