//
//  FoodCollectionViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/28/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class FoodCollectionViewModel {
    private let food: Food
    var sections: [ItemGroup] {
        return food.itemGroups
    }
    
    var didTapEdit: ((ItemType) -> ())?
    
    init(food: Food) {
        self.food = food
    }
}
