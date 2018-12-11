//
//  HomeViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

struct HomeViewModelParcel {
	let userState: UserState
}

protocol HomeViewModelViewDelegate {
	func cellWidth() -> Double
	func cellHeight() -> Double
}

enum HomeCellIdentifier: String {
	case homePurchasableCategoryCell
}

class HomeViewModel {
	typealias Section = AnyViewModelCollectionViewSection
	
	var parcel: HomeViewModelParcel?
	private let viewDelegate: HomeViewModelViewDelegate
	
	private let purchasablesAPIManager = PurchasablesAPIManager()
	private let bagModelController = BagModelController()
	private let userAPIManager = UserAPIManager()
	
	lazy var userState = { parcel?.userState ?? .noUser }()
	
	private var categories = [PurchasableCategoryNode]()
	private var sections: [Section] { return [
		Section(cellViewModels: categories
			.map { HomePurchasableCategoryCollectionViewCellViewModelFactory.init(title: $0.title, identifier: HomeCellIdentifier.homePurchasableCategoryCell.rawValue, width: viewDelegate.cellWidth(), height: viewDelegate.cellHeight()).create() }
		)
	]}
	
	var numberOfSections: Int {
		return sections.count
	}
    
	init(parcel: HomeViewModelParcel?, viewDelegate: HomeViewModelViewDelegate) {
		self.parcel = parcel
		self.viewDelegate = viewDelegate
		
		userAPIManager.currentUserState()
			.get { self.userState = $0 }.catch { print($0) }
    }
	
	func setupData() -> Promise<Void> {
		return purchasablesAPIManager.categories()
			.get { self.categories = $0 }.asVoid()
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
	
	func purchasableFavorites(for user: User) -> Promise<[Purchasable]> {
		return userAPIManager.purchasableFavorites(for: user)
			.mapValues { $0.purchasable }
	}
}
