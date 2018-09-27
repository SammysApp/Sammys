//
//  HomeViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

/// A value that represents the state of the home view.
enum HomeViewState {
    case foods, faves
}

protocol HomeViewModelDelegate {
    
}

private struct Section {
    let title: String?
    let cellViewModels: [CollectionViewCellViewModel]
    
    init(title: String? = nil, cellViewModels: [CollectionViewCellViewModel]) {
        self.title = title
        self.cellViewModels = cellViewModels
    }
}

class HomeViewModel {
    var delegate: HomeViewModelDelegate?
    
    private(set) var currentViewState = HomeViewState.foods
    private var sections = [Section]()
    
    var numberOfSections: Int {
        return sections.count
    }
    
    var bagQuantityLabelText: String {
        let quantity = BagDataStore.shared.quantity
        return quantity > 0 ? "\(quantity)" : ""
    }
    
    var favesButtonImage: UIImage {
        return currentViewState == .faves ? #imageLiteral(resourceName: "Home.pdf") : #imageLiteral(resourceName: "Heart.pdf")
    }
    
    init() {
        setSectionsWithFood()
    }
    
    private func setSectionsWithFood() {
        sections = [
            Section(cellViewModels: [
                FoodHomeCollectionViewCellViewModelFactory(
                    size: cellSize(for: .foods),
                    titleText: FoodType.salad.title,
                    selectionCommand: FoodHomeCollectionViewCellSelectionCommand(didSelect: {
						//self.delegate?.didSelectFood()
					})).create()
            ])
        ]
    }
    
    func numberOfItems(in section: Int) -> Int {
        return sections[section].cellViewModels.count
    }
    
    func cellViewModel(for indexPath: IndexPath) -> CollectionViewCellViewModel {
        return sections[indexPath.section].cellViewModels[indexPath.row]
    }
    
    func title(for section: Int) -> String? {
        return sections[section].title
    }
    
    private func cellSize(for viewKey: HomeViewState) -> CGSize {
//        switch viewKey {
//        case .foods: return CGSize(width: contextBounds.width - 20, height: 200)
//        case .faves:
//            let size = (contextBounds.width / 2) - 15
//            return CGSize(width: size, height: size)
//        }
		return CGSize()
    }
    
    func setupView(for viewKey: HomeViewState) {
        switch viewKey {
        case .foods:
            self.currentViewState = viewKey
            setSectionsWithFood()
//            delegate?.collectionViewDataDidChange()
        case .faves: break
        }
    }
    
    func toggleFavesView() {
        if currentViewState == .faves {
            setupView(for: .foods)
        } else {
            setupView(for: .faves)
        }
    }
}
