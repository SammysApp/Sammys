//
//  FoodsDataStore.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/7/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

/// A singleton type that stores 📦 all available foods 🍎.
class FoodsDataStore {
    /// The shared single instance.
    static let shared = FoodsDataStore()
    
    /// The available foods represented as a `Foods struct`.
    var foodsData: FoodsData?
    
    private struct Constants {
        static let foodsFileName = "Foods"
    }
    
    private init() {
        // Set `foods` from Foods.json file.
        do {
            let foodsData: FoodsData = try JSONDecoder().decodeFixture(name: Constants.foodsFileName)
            self.foodsData = foodsData
        }
        catch {
            print(error)
        }
    }
}

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
