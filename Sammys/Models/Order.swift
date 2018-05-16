//
//  Order.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/23/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

typealias Foods = [FoodType : [Food]]
private typealias SavedFoods = [FoodType : [AnyFood]]

struct Order: Codable {
    let id: String
    let userName: String
    let userID: String
    let number: String
    let date: Date
    let foods: Foods
    
    enum CodingKeys: CodingKey {
        case id, userName, userID, number, date, foods
    }
    
    init(number: String, userName: String, userID: String, date: Date, foods: [FoodType : [Food]]) {
        self.id = UUID().uuidString
        self.userName = userName
        self.userID = userID
        self.number = number
        self.date = date
        self.foods = foods
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.userName = try container.decode(String.self, forKey: .userName)
        self.userID = try container.decode(String.self, forKey: .userID)
        self.number = try container.decode(String.self, forKey: .number)
        self.date = try container.decode(Date.self, forKey: .date)
        let savedFoods = try container.decode(SavedFoods.self, forKey: .foods)
        self.foods = savedFoods.encodableUnwrapped()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(id, forKey: .userName)
        try container.encode(id, forKey: .userID)
        try container.encode(number, forKey: .number)
        try container.encode(date, forKey: .date)
        try container.encode(foods.toEncodable(), forKey: .foods)
    }
}

extension Order {
    var subtotalPrice: Double {
        var totalPrice = 0.0
        foods.forEach { $1.forEach { totalPrice += $0.price } }
        return totalPrice.rounded(toPlaces: 2)
    }
    
    var taxPrice: Double {
        return (subtotalPrice * (6.88/100)).rounded(toPlaces: 2)
    }
    
    var totalPrice: Double {
        return (subtotalPrice + taxPrice).rounded(toPlaces: 2)
    }
}

private extension Dictionary where Key == FoodType, Value == [Food] {
    func toEncodable() -> SavedFoods {
        return self.mapValues { $0.map { AnyFood($0) } }
    }
}

private extension Dictionary where Key == FoodType, Value == [AnyFood] {
    func encodableUnwrapped() -> Foods {
        return self.mapValues { $0.map { $0.food } }
    }
}
