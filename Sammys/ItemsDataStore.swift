//
//  ItemsDataStore.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/7/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

class ItemsDataStore {
    static let shared = ItemsDataStore()
    var items: Items?
    
    private init() {
        if let path = Bundle.main.path(forResource: "Items", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let items = try JSONDecoder().decode(Items.self, from: data)
                self.items = items
            }
            catch {
                print(error)
                return
            }
        }
    }
}

struct Items: Decodable {
    let salad: Salad
    
    struct Salad: Decodable {
        let sizes: [Size]
        let lettuce: [Lettuce]
        let vegetables: [Vegetable]
        let toppings: [Topping]
        let dressings: [Dressing]
    }
}
