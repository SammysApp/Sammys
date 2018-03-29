//
//  AddViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/28/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol AddViewModelDelegate {
    func didTapEdit()
}

class AddViewModel {
    var delegate: AddViewModelDelegate?
    
    private let food: Food
    private let editDelegate: ItemEditable?
    
    lazy var collectionViewModel: FoodCollectionViewModel = {
        let collectionViewModel = FoodCollectionViewModel(food: food)
        collectionViewModel.didTapEdit = {
            self.editDelegate?.edit(for: $0)
            self.delegate?.didTapEdit()
        }
        return collectionViewModel
    }()
    
    init(food: Food, editDelegate: ItemEditable? = nil) {
        self.food = food
        self.editDelegate = editDelegate
    }
    
    func addFoodToBag() {
        BagDataStore.shared.add(food)
    }
    
    func addFoodAsFave() {
        UserAPIClient.set(food as! Salad, for: UserDataStore.shared.user!)
    }
}
