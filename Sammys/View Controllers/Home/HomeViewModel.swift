//
//  HomeViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

enum HomeViewState {
    case foods, faves
}

private struct Section {
    let title: String?
    let cellViewModels: [CollectionViewCellViewModel]
    
    init(title: String? = nil, cellViewModels: [CollectionViewCellViewModel]) {
        self.title = title
        self.cellViewModels = cellViewModels
    }
}

protocol HomeViewModelDelegate {
	var contextBounds: CGSize { get }
}

class HomeViewModel {
	let delegate: HomeViewModelDelegate
	private var sections = [Section]()
	
	/// Gets updated to given value of `setCurrentViewState(:)`.
    private(set) var currentViewState = Dynamic(HomeViewState.foods)
	/// Gets updated when the current view state is set.
	private(set) var favesButtonImage = Dynamic(#imageLiteral(resourceName: "Heart.pdf"))
	private (set) var shouldHideNoFavesView = Dynamic(true)
    
    var bagQuantityLabelText: String {
		return ""
    }
	
	var numberOfSections: Int {
		return sections.count
	}
	
	// ⚠️ Fetch foods to list from database. For now only salad.
	private lazy var foodSections: [Section] = {[
		Section(cellViewModels: [
			FoodHomeCollectionViewCellViewModelFactory(
				size: cellSize(for: .foods),
				titleText: FoodType.salad.title
			).create()
		])
	]}()
	
	private struct Constants {
		static let foodCellHeight: CGFloat = 200
	}
    
	init(delegate: HomeViewModelDelegate) {
		self.delegate = delegate
		setUpSections(for: currentViewState.value)
    }
	
	func setCurrentViewState(to viewState: HomeViewState) {
		currentViewState.value = viewState
		setFavesButtonImage(for: viewState)
	}
	
	func setFavesButtonImage(for viewState: HomeViewState) {
		switch viewState {
		case .foods: favesButtonImage.value = #imageLiteral(resourceName: "Heart.pdf")
		case .faves: favesButtonImage.value = #imageLiteral(resourceName: "Home.pdf")
		}
	}
    
    private func setUpSections(for viewState: HomeViewState) {
		switch viewState {
		case .foods: sections = foodSections
		case .faves: break
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
    
    private func cellSize(for viewState: HomeViewState) -> CGSize {
        switch viewState {
        case .foods: return CGSize(width: delegate.contextBounds.width - 20, height: Constants.foodCellHeight)
        case .faves:
            let size = (delegate.contextBounds.width / 2) - 15
            return CGSize(width: size, height: size)
        }
    }
}
