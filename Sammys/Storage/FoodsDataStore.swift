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
    var foods: Foods?
    
    private struct Constants {
        static let foodsFileName = "Foods"
        static let foodsFileType = "json"
    }
    
    private init() {
        // Set `foods` from Foods.json file.
        if let path = Bundle.main.path(forResource: Constants.foodsFileName, ofType: Constants.foodsFileType) {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let foods = try JSONDecoder().decode(Foods.self, from: data)
                self.foods = foods
            }
            catch {
                print(error)
            }
        }
    }
}

/// A type representing all available foods.
struct Foods: Decodable {
    let salad: Salad
    
    struct Salad: Decodable {
        let sizes: [Size]
        let lettuce: [Lettuce]
        let vegetables: [Vegetable]
        let toppings: [Topping]
        let dressings: [Dressing]
    }
}
