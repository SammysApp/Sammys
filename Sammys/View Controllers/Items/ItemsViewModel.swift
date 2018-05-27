//
//  ItemsViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/22/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

enum ItemsViewLayoutState {
    case horizontal, vertical
}

protocol ItemsViewModelDelegate {
    var choiceDidChange: () -> () { get }
    func showModifiers(for item: Item)
}

class ItemsViewModel {
    private typealias Choice = SaladItemType
    
    var delegate: ItemsViewModelDelegate?
    
    var food: Food {
        return salad
    }
    
    private var data: FoodsData?
    
    private let choices = Choice.all
    
    private var salad = Salad()
    
    private var currentChoiceIndex = 0 {
        didSet {
            delegate?.choiceDidChange()
        }
    }
    
    private var currentChoice: Choice {
        return choices[currentChoiceIndex]
    }
    
    var atFirstChoice: Bool {
        return currentChoiceIndex == 0
    }
    
    var atLastChoice: Bool {
        return currentChoiceIndex == choices.endIndex - 1
    }
    
    var items: [Item] {
        return data?.salad.allItems[currentChoice] ?? []
    }
    
    var currentViewLayoutState: ItemsViewLayoutState {
        if currentChoice == .size || currentChoice == .lettuce {
            return .horizontal
        }
        return .vertical
    }
    
    var itemTypeLabelText: String {
        return currentChoice.title
    }
    
    var shouldHideItemLabel: Bool {
        return currentViewLayoutState == .vertical
    }
    
    var shouldHidePriceLabel: Bool {
        return currentViewLayoutState == .vertical || currentChoice == .lettuce
    }
    
    var numberOfSections: Int {
        return 1
    }
    
    var numberOfItems: Int {
        return items.count
    }
    
    var collectionViewInsets: UIEdgeInsets {
        switch currentChoice {
        case .vegetable, .topping, .dressing, .extra:
            return UIEdgeInsets(top: 80, left: 10, bottom: 60, right: 10)
        default:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    var collectionViewMinimumLineSpacing: CGFloat {
        switch currentChoice {
        case .vegetable, .topping, .dressing, .extra:
            return 10
        default:
            return 0
        }
    }
    
    var collectionViewMinimumInteritemSpacing: CGFloat {
        switch currentChoice {
        case .vegetable, .topping, .dressing, .extra:
            return 10
        default:
            return .greatestFiniteMagnitude
        }
    }
    
    func setData(completed: (() -> Void)? = nil) {
        FoodsDataStore.shared.setFoods { data in
            self.data = data
            completed?()
        }
    }
    
    func resetFood(to food: Food) {
        guard let salad = food as? Salad else { return }
        self.salad = salad
    }
    
    func priceLabelText(at index: Int) -> String? {
        guard !items.isEmpty,
            currentChoice == .size,
            let size = items[index] as? Size
            else { return nil }
        return "$\(size.price)"
    }
    
    func cellViewModels(for contextBounds: CGRect) -> [CollectionViewCellViewModel] {
        guard !items.isEmpty else { return [] }
        let size = cellSize(for: currentChoice, contextBounds: contextBounds)
        return items.map { item in
            var shouldHideItemLabel = false
            if let saladItemType = type(of: item).type as? SaladItemType,
                saladItemType == .size || saladItemType == .lettuce {
                shouldHideItemLabel = true
            }
            return ItemCollectionViewCellViewModelFactory(item: item, size: size, shouldHideItemLabel: shouldHideItemLabel, shouldShowSelected: salad.contains(item)).create()
        }
    }
    
    private func cellSize(for itemType: SaladItemType, contextBounds: CGRect) -> CGSize {
        switch itemType {
        case .vegetable, .topping, .dressing, .extra:
            let size = (contextBounds.width/2) - 15
            return CGSize(width: size, height: size)
        default:
            return CGSize(width: contextBounds.width, height: contextBounds.height/1.5)
        }
    }
    
    func goToNextChoice() {
        guard currentChoiceIndex + 1 < choices.endIndex else { return }
        currentChoiceIndex += 1
    }
    
    func goToPreviousChoice() {
        guard currentChoiceIndex - 1 >= 0 else { return }
        currentChoiceIndex -= 1
    }
    
    func handleItemSelection(at index: Int) {
        guard !items.isEmpty else { return }
        let item = items[index]
        if item.modifiers != nil {
            delegate?.showModifiers(for: item)
        } else {
            toggle(item: item)
        }
    }
    
    func toggle(item: Item) {
        if let size = item as? Size {
            salad.size = size
        } else {
            salad.toggle(item)
        }
    }
    
    func toggleModifier(_ modifier: Modifier, for item: Item) {
        salad.toggle(modifier, for: item)
    }
}

// MARK: - ItemEditable
extension ItemsViewModel: ItemEditable {
    func edit(for itemType: ItemType) {
        guard let choice = itemType as? Choice else { return }
        if let choiceIndex = choices.index(of: choice) {
            currentChoiceIndex = choiceIndex
        }
    }
}
