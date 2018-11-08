//
//  HomeItemCollectionViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/4/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum HomeItemCellIdentifier: String {
    case homeItemCell
}

struct HomeItemCollectionViewCellViewModelFactory: CollectionViewCellViewModelFactory {
	let width: Double
	let height: Double
    let titleText: String
    
    func create() -> DefaultCollectionViewCellViewModel {
        return DefaultCollectionViewCellViewModel(identifier: HomeItemCellIdentifier.homeItemCell.rawValue, width: width, height: height, commands: [.configuration: HomeItemCollectionViewCellConfigurationCommand(titleText: titleText)])
    }
}
