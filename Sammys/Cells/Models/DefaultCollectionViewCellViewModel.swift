//
//  DefaultCollectionViewCellViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/4/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct DefaultCollectionViewCellViewModel: CollectionViewCellViewModel {
	let identifier: String
	let size: CGSize
	let commands: [CollectionViewCommandActionKey : CollectionViewCellCommand]
}
