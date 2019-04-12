//
//  Category.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/20/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

final class Category: Codable {
    typealias ID = UUID
    
    let id: ID
    let name: String
    let imageURL: String?
    let minimumItems: Int?
    let maximumItems: Int?
    let isParentCategory: Bool?
    let isConstructable: Bool
}
