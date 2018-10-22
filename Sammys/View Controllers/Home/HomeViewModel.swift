//
//  HomeViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum HomeViewState {
    case home, faves
}

private struct HomeItem {
	let title: String
}

private struct Section {
    let title: String?
    let cellViewModels: [CollectionViewCellViewModel]
    
    init(title: String? = nil, cellViewModels: [CollectionViewCellViewModel]) {
        self.title = title
        self.cellViewModels = cellViewModels
    }
}

protocol HomeViewModelViewDelegate {
	func cellWidth(for state: HomeViewState) -> Double
	func cellHeight(for state: HomeViewState) -> Double
}

class HomeViewModel {
	let viewDelegate: HomeViewModelViewDelegate
	private let bagModelController = BagModelController()
	
	private let homeItems: [HomeItem] = [
		HomeItem(title: "Salad")
	]
	
	private var sections: [Section] {
		switch currentViewState.value {
		case .home: return homeSections
		case .faves: return []
		}
	}
	
	// ⚠️ Fetch foods to list from database and create models.
	private var homeSections: [Section] { return [
		Section(cellViewModels: homeItems.map {
			HomeItemCollectionViewCellViewModelFactory(
				width: viewDelegate.cellWidth(for: currentViewState.value),
				height: viewDelegate.cellHeight(for: currentViewState.value),
				titleText: $0.title
			).create()
		})
	]}
	
	private(set) var currentViewState = Dynamic(HomeViewState.home)
	private(set) var favesButtonImage = Dynamic(HomeImage.heart)
	private (set) var shouldHideNoFavesView = Dynamic(true)
	
	var bagQuantity: Int {
		return (try? bagModelController.getQuantity()) ?? 0
	}
    
    var bagQuantityLabelText: String? {
		return bagQuantity > 0 ? "\(bagQuantity)" : nil
    }
	
	var numberOfSections: Int {
		return sections.count
	}
    
	init(_ viewDelegate: HomeViewModelViewDelegate) {
		self.viewDelegate = viewDelegate
    }
	
	func setCurrentViewState(to viewState: HomeViewState) {
		currentViewState.value = viewState
		setFavesButtonImage(for: viewState)
	}
	
	func setFavesButtonImage(for viewState: HomeViewState) {
		switch viewState {
		case .home: favesButtonImage.value = .heart
		case .faves: favesButtonImage.value = .home
		}
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
}
