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
    
    var price: Double { get set }
    var itemDictionary: ItemsDictionary { get }
}

enum FoodKey: String, Codable {
    case salad = "Salad"
}
