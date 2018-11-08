//
//  BagViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/28/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol BagViewModelViewDelegate {
	func cellHeight() -> Double
}

class BagViewModel {
	typealias Section = TableViewSection<BagFoodTableViewCellViewModel>
	
	private let viewDelegate: BagViewModelViewDelegate
	
	private let bagModelController = BagModelController()
	private var foods: [Food] {
		do { return try getFoods() } catch { print(error); return [] }
	}
	private var sections: [Section] {
		return [
			Section(cellViewModels: foods
				.map { BagFoodTableViewCellViewModelFactory(food: $0, height: viewDelegate.cellHeight()).create() }
			)
		]
	}
	
	var numberOfSections: Int { return sections.count }
	
	init(_ viewDelegate: BagViewModelViewDelegate) {
		self.viewDelegate = viewDelegate
	}
	
	private func getFoods() throws -> [Food] {
		return try bagModelController.getPurchasableQuantities()
			.compactMap { $0.purchaseable as? Food }
	}
	
	func numberOfRows(inSection section: Int) -> Int {
		return sections[section].cellViewModels.count
	}
	
	func cellViewModel(for indexPath: IndexPath) -> Section.CellViewModel {
		return sections[indexPath.section].cellViewModels[indexPath.row]
	}
}
