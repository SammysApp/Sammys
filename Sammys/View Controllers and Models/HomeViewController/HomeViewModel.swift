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
	let purchasableType: Purchasable.Type
}

protocol HomeViewModelViewDelegate {
	func cellWidth(for state: HomeViewState) -> Double
	func cellHeight(for state: HomeViewState) -> Double
}

class HomeViewModel {
	typealias HomeCollectionViewSection = CollectionViewSection<DefaultCollectionViewCellViewModel>
	
	let viewDelegate: HomeViewModelViewDelegate
	private let bagModelController = BagModelController()
	
	// MARK: - Data
	private let homeItems: [HomeItem] = [
		HomeItem(title: "Salad", purchasableType: Salad.self)
	]
	
	private var sections: [HomeCollectionViewSection] {
		switch currentViewState.value {
		case .home: return homeSections
		case .faves: return []
		}
	}
	
	private var homeSections: [HomeCollectionViewSection] { return [
		CollectionViewSection(cellViewModels: homeItems.map {
			HomeItemCollectionViewCellViewModelFactory(
				width: viewDelegate.cellWidth(for: currentViewState.value),
				height: viewDelegate.cellHeight(for: currentViewState.value),
				titleText: $0.title
			).create()
		})
	]}
	
	// MARK: - Dynamic Properties
	private(set) var currentViewState = Dynamic(HomeViewState.home)
	private(set) var favesButtonImage = Dynamic(HomeImage.heart)
	private (set) var shouldHideNoFavesView = Dynamic(true)
	
	let userAPIManager = UserAPIManager()
	var userState = UserState.noUser
	
	var bagQuantity: Int {
		return (try? bagModelController.getTotalPurchasablesQuantity()) ?? 0
	}
    
    var bagQuantityLabelText: String? {
		return bagQuantity > 0 ? "\(bagQuantity)" : nil
    }
	
	var numberOfSections: Int {
		return sections.count
	}
    
	init(_ viewDelegate: HomeViewModelViewDelegate) {
		self.viewDelegate = viewDelegate
		
		userAPIManager.currentUserState().get { self.userState = $0 }.catch { print($0) }
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
	
	func builderViewModelParcel(for indexPath: IndexPath) -> BuilderViewModelParcel? {
		guard let itemedPurchasableType = homeItems[indexPath.section].purchasableType as? ItemedPurchasable.Type else { return nil }
		return BuilderViewModelParcel.instance(for: itemedPurchasableType)
	}
	
	func userViewModelParcel() -> UserViewModelParcel {
		return UserViewModelParcel(userState: userState)
	}
}
