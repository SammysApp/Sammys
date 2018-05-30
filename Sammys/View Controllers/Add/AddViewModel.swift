//
//  AddViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/28/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol AddViewModelDelegate {
    func didTapEdit()
    func edit(for itemType: ItemType, with food: Food)
    func didUpdateFave()
}

class AddViewModel {
    var delegate: AddViewModelDelegate?
    
    private let food: Food
    private let editDelegate: ItemEditable?
    
    var didGoBack: ((AddViewController, Food?) -> Void)?
    var shouldUnfave = false
    var didRemove = false
    
    var user: User? {
        return UserDataStore.shared.user
    }
    
    var title: String {
        return food.price.priceString
    }
    
    var faveButtonImage: UIImage {
        return shouldUnfave ? #imageLiteral(resourceName: "Heart Cross Bar.pdf") : #imageLiteral(resourceName: "Heart Bar.pdf")
    }
    
    lazy var collectionViewModel: FoodCollectionViewModel = {
        let collectionViewModel = FoodCollectionViewModel(food: food)
        collectionViewModel.didTapEdit = {
            self.editDelegate?.edit(for: $0) ?? self.delegate?.edit(for: $0, with: self.food)
            self.delegate?.didTapEdit()
        }
        return collectionViewModel
    }()
    
    init(food: Food, editDelegate: ItemEditable? = nil) {
        self.food = food
        self.editDelegate = editDelegate
    }
    
    func handleMovingFromParentViewController(_ addViewController: AddViewController) {
        didGoBack?(addViewController, didRemove ? nil : food)
    }
    
    func handleDidTapFave() {
        if shouldUnfave { removeFoodAsFave() }
        else { addFoodAsFave() }
    }
    
    func addFoodToBag() {
        BagDataStore.shared.add(food)
    }
    
    func addFoodAsFave() {
        guard let user = user else { return }
        UserAPIClient.set(food, for: user)
        // FIXME: add to completed closure
        shouldUnfave = true
        delegate?.didUpdateFave()
    }
    
    func removeFoodAsFave() {
        guard let user = user else { return }
        UserAPIClient.remove(food, for: user)
        didRemove = true
        shouldUnfave = false
        delegate?.didUpdateFave()
    }
}
