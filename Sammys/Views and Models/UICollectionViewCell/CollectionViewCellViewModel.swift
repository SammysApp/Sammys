//
//  CollectionViewCellViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/22/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol CollectionViewCellViewModel {
	var identifier: String { get }
	var width: Double { get }
	var height: Double { get }
	var commands: [CollectionViewCellCommandAction: CollectionViewCellCommand] { get }
}
