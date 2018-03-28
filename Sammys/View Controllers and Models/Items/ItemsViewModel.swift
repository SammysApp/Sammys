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

class ItemsViewModel {
    typealias Choice = SaladItemType
    
    private let data = FoodsDataStore.shared.foodsData!
    
    private let choices = Choice.all
    
    private var salad = Salad()
    
    private var currentChoiceIndex = 0
    
    var currentChoice: Choice {
        return choices[currentChoiceIndex]
    }
    
    var atFirstChoice: Bool {
        return currentChoiceIndex == 0
    }
    
    var atLastChoice: Bool {
        return currentChoiceIndex == choices.endIndex - 1
    }
    
    var items: [Item] {
        return data.salad.allItems[currentChoice] ?? []
    }
    
    var currentViewLayoutState: ItemsViewLayoutState {
        if currentChoice == .size || currentChoice == .lettuce {
            return .horizontal
        }
        return .vertical
    }
    
    var priceButtonTitle: String {
        return "$\(salad.price)"
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
        case .vegetable, .topping, .dressing:
            return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        default:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    var collectionViewMinimumLineSpacing: CGFloat {
        switch currentChoice {
        case .vegetable, .topping, .dressing:
            return 10
        default:
            return 0
        }
    }
    
    var collectionViewMinimumInteritemSpacing: CGFloat {
        switch currentChoice {
        case .vegetable, .topping, .dressing:
            return 10
        default:
            return .greatestFiniteMagnitude
        }
    }
    
    func priceLabelText(at index: Int) -> String? {
        if currentChoice == .size,
            let size = items[index] as? Size {
            return "$\(size.price)"
        }
        return nil
    }
    
    func cellViewModels(for contextBounds: CGRect) -> [CellViewModel] {
        let size = cellSize(for: currentChoice, contextBounds: contextBounds)
        return items.map { ItemCollectionViewCellViewModelFactory(item: $0, size: size).create() }
    }
    
    private func cellSize(for itemType: SaladItemType, contextBounds: CGRect) -> CGSize {
        switch itemType {
        case .vegetable, .topping, .dressing:
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
    
    func toggleItem(at index: Int) {
        let item = items[index]
        if let size = item as? Size {
            salad.size = size
        } else {
            salad.toggle(item)
        }
    }
}

// MARK: - Choice
private extension ItemsViewModel.Choice {
    init?(_ title: String) {
        if let choice = SaladItemType.type(for: title) {
            self = choice
        }
        return nil
    }
}
