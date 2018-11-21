//
//  HomeViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct HomeViewModelParcel {
	let userState: UserState
}

protocol HomeViewModelViewDelegate {
	func cellWidth(for state: HomeViewState) -> Double
	func cellHeight(for state: HomeViewState) -> Double
}

enum HomeCellIdentifier: String {
	case homePurchasableCell
}

enum HomeViewState {
	case home, faves
}

class HomeViewModel {
	typealias Section = AnyViewModelCollectionViewSection
	
	private let parcel: HomeViewModelParcel
	private let viewDelegate: HomeViewModelViewDelegate
	
	private let bagModelController = BagModelController()
	private let userAPIManager = UserAPIManager()
	
	var currentViewState = HomeViewState.home
	lazy var userState = { parcel.userState }()
	
	// MARK: - Data
	private var sections: [Section] {
		switch currentViewState {
		case .home: return homeSections
		case .faves: return []
		}
	}
	
	private var homeSections: [Section] { return [
		Section(cellViewModels: [
			HomePurchasableTypeCollectionViewCellViewModelFactory(
				purchasableType: Salad.self,
				identifier: HomeCellIdentifier.homePurchasableCell.rawValue,
				width: viewDelegate.cellWidth(for: currentViewState),
				height: viewDelegate.cellHeight(for: currentViewState)
			).create()
		])
	]}
	
	var numberOfSections: Int {
		return sections.count
	}
    
	init(parcel: HomeViewModelParcel, viewDelegate: HomeViewModelViewDelegate) {
		self.parcel = parcel
		self.viewDelegate = viewDelegate
		
		userAPIManager.currentUserState().get { self.userState = $0 }.catch { print($0) }
    }
    
    func numberOfItems(in section: Int) -> Int {
        return sections[section].cellViewModels.count
    }
    
    func cellViewModel(for indexPath: IndexPath) -> Section.CellViewModel? {
		return sections[safe: indexPath.section]?.cellViewModels[safe: indexPath.row]
    }
    
    func title(for section: Int) -> String? {
        return sections[section].title
    }
}
