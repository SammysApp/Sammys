//
//  SaladBuilder.swift
//  Sammys
//
//  Created by Natanel Niazoff on 10/18/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum SaladBuilderError: Error {
	case needsSize
}

private struct SaladBuilder: ItemedPurchasableBuilder {
	var items = [Item]()
	var modifiers = [AnyHashableProtocol : [Modifier]]()
	
	private func buildSize() throws -> Size {
		guard let size = items.compactMap({ $0 as? Size }).first
			else { throw SaladBuilderError.needsSize }
		return size
	}
	
	private func buildLettuce() -> [Lettuce] {
		return []
	}
	
	private func buildVegetables() -> [Vegetable] {
		return items.compactMap { $0 as? Vegetable }
	}
	
	private func buildToppings() -> [Topping] {
		return items.compactMap { $0 as? Topping }
	}
	
	private func buildDressings() -> [Dressing] {
		return []
	}
	
	private func buildExtras() -> [Extra] {
		return []
	}
	
	func build() throws -> ItemedPurchasable {
		return Salad(
			size: try buildSize(),
			lettuces: buildLettuce(),
			vegetables: buildVegetables(),
			toppings: buildToppings(),
			dressings: buildDressings(),
			extras: buildExtras()
		)
	}
}

extension Salad: ItemedPurchasableBuildable {
	static var builder: ItemedPurchasableBuilder { return SaladBuilder() }
}
