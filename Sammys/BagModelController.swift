//
//  BagModelController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/8/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct BagModelController {
    typealias Foods = [FoodType: [Food]]
    private typealias StorableFoods = [FoodType : [AnyFood]]
	
	private struct Constants {
		static let foodsDataKey = "foods"
	}
    
    private func storableFoods(for foods: Foods) -> StorableFoods {
        return foods.mapValues { $0.map { AnyFood($0) } }
    }
	
	private func foods(for storableFoods: StorableFoods) -> Foods {
		return storableFoods.mapValues { $0.map { $0.food } }
	}
	
	private func store(foods: Foods) throws {
		UserDefaults.standard.set(
			try JSONEncoder().encode(storableFoods(for: foods)),
			forKey: Constants.foodsDataKey
		)
	}
	
	func getFoods() throws -> Foods {
		if let foodData = UserDefaults.standard.data(forKey: Constants.foodsDataKey) {
			do {
				return foods(for: try JSONDecoder().decode(StorableFoods.self, from: foodData))
			} catch { throw error }
		} else { fatalError("No data for for this key.") }
	}
	
    func add(_ food: Food) throws {
		do {
			let foods = try getFoods()
			
		} catch { throw error }
    }
}
