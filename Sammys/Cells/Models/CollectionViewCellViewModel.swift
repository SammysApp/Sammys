//
//  CollectionViewCellViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/22/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol CollectionViewCellViewModel {
	var identifier: String { get }
	var size: CGSize { get }
	var commands: [CollectionViewCommandActionKey: CollectionViewCellCommand] { get }
}
