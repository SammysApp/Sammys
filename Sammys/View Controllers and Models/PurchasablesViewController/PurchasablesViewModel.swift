//
//  PurchasablesViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 12/5/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

struct PurchasablesViewModelParcel {
	let purchasables: Promise<[Purchasable]>
	let layout: PurchasablesLayout
}

protocol PurchasablesViewModelViewDelegate {
	func cellHeight() -> Double
}

enum PurchasablesLayout {
	case basic, categorized
}

enum PurchasablesCellIdentifier: String {
	case purchasableCell
}

enum PurchasablesViewModelError: Error {
	case needsParcel
}

typealias PurchasableCategoryDictionary = [PurchasableCategory : [Purchasable]]

class PurchasablesViewModel {
	typealias Section = DefaultTableViewSection<PurchasablesPurchasableTableViewCellViewModel>
	typealias CategorizedSection = PurchasablesCategorizedTableViewSection
	
	var parcel: PurchasablesViewModelParcel?
	private let viewDelegate: PurchasablesViewModelViewDelegate
	
	private var purchasables = [Purchasable]()
	lazy var layout = { parcel?.layout ?? .basic }()
	
	var sections: [Section] {
		return [Section(cellViewModels: cellViewModels(for: purchasables))]
	}
	
	var categorizedSections: [CategorizedSection] {
		return purchasables.categorized().map {
			CategorizedSection(category: $0, cellViewModels: cellViewModels(for: $1))
		}
	}
	
	var numberOfSections: Int {
		switch layout {
		case .basic: return sections.count
		case .categorized: return categorizedSections.count
		}
	}
	
	init(parcel: PurchasablesViewModelParcel?, viewDelegate: PurchasablesViewModelViewDelegate) {
		self.parcel = parcel
		self.viewDelegate = viewDelegate
	}
	
	func setupData() -> Promise<Void> {
		guard let parcel = parcel
			else { return Promise(error: PurchasablesViewModelError.needsParcel) }
		return parcel.purchasables.get { self.purchasables = $0 }.asVoid()
	}
	
	private func cellViewModels(for purchasables: [Purchasable]) -> [PurchasablesPurchasableTableViewCellViewModel] {
		return purchasables.map {
			PurchasablesPurchasableTableViewCellViewModelFactory(
				purchasable: $0,
				identifier: PurchasablesCellIdentifier.purchasableCell.rawValue,
				height: viewDelegate.cellHeight()
			).create()
		}
	}
	
	func numberOfRows(inSection section: Int) -> Int {
		switch layout {
		case .basic: return sections[section].cellViewModels.count
		case .categorized: return categorizedSections[section].cellViewModels.count
		}
	}
	
	func cellViewModel(for indexPath: IndexPath) -> TableViewCellViewModel? {
		switch layout {
		case .basic: return sections[safe: indexPath.section]?
				.cellViewModels[safe: indexPath.row]
		case .categorized:
			return categorizedSections[safe: indexPath.section]?
				.cellViewModels[safe: indexPath.row]
		}
	}
	
	func title(forSection section: Int) -> String? {
		return nil
//		switch layout {
//		case .basic: return sections[section].title
//		case .categorized: return categorizedSections[section].category.name
//		}
	}
}

private extension Array where Element == Purchasable {
	func categorized() -> PurchasableCategoryDictionary {
		var purchasableCategoryDict = PurchasableCategoryDictionary()
		for purchasable in self {
			guard let purchasables = purchasableCategoryDict[purchasable.category]
				else { purchasableCategoryDict[purchasable.category] = [purchasable]; continue }
			purchasableCategoryDict[purchasable.category] = purchasables.appending(purchasable)
		}
		return purchasableCategoryDict
	}
}
