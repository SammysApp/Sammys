//
//  Food.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/9/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol Food: Codable {
    typealias ItemsDictionary = [Int : (title: String, items: [Item])]
    
    static var type: FoodType { get }
    var id: String { get }
    var title: String { get }
    var quantity: Int { get set }
    var price: Double { get }
    var itemDescription: String { get }
    var itemDictionary: ItemsDictionary { get }
}

extension Food {
    func isEqual(_ food: Food) -> Bool {
        if let selfSalad = self as? Salad, let foodSalad = food as? Salad {
            return selfSalad == foodSalad
        }
        return false
    }
}

enum FoodType: String, Codable {
    case salad = "Salad"
    
    var metatype: Food.Type {
        switch self {
        case .salad:
            return Salad.self
        }
    }
}

struct AnyFood: Codable {
    let food: Food
    
    init(_ food: Food) {
        self.food = food
    }
    
    private enum CodingKeys: CodingKey {
        case type, food
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(FoodType.self, forKey: .type)
        self.food = try type.metatype.init(from: container.superDecoder(forKey: .food))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type(of: food).type, forKey: .type)
        try food.encode(to: container.superEncoder(forKey: .food))
    }
}
