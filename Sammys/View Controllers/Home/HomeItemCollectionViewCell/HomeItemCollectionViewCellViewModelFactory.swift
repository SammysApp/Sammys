//
//  HomeItemCollectionViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/4/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

enum HomeItemCellIdentifier: String {
    case homeItemCell
}

struct HomeItemCollectionViewCellViewModelFactory: CollectionViewCellViewModelFactory {
	let width: Double
	let height: Double
    let titleText: String
	
	var size: CGSize {
		return CGSize(width: width, height: height)
	}
    
    func create() -> CollectionViewCellViewModel {
        let configurationCommand = HomeItemCollectionViewCellConfigurationCommand(titleText: titleText)
        let commands: [CollectionViewCommandActionKey : CollectionViewCellCommand] = [.configuration: configurationCommand]
        return CollectionViewCellViewModel(identifier: HomeItemCellIdentifier.homeItemCell.rawValue, size: size, commands: commands)
    }
}
