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
    let salad: Salad
    
    struct Salad: Decodable {
        let sizes: [Size]
        let lettuce: [Lettuce]
        let vegetables: [Vegetable]
        let toppings: [Topping]
        let dressings: [Dressing]
        
        var allItems: [SaladItemType : [Item]] {
            return [
                .size: sizes,
                .lettuce: lettuce,
                .vegetable: vegetables,
                .topping: toppings,
                .dressing: dressings,
            ]
        }
    }
}

enum FixtureError: Error {
    case fileNotFound
}

extension JSONDecoder {
    func decodeFixture<T>(name: String, bundle: Bundle = .main) throws -> T where T: Decodable {
        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            throw FixtureError.fileNotFound
        }
        
        let data = try Data(contentsOf: url)
        return try decode(T.self, from: data)
    }
}
