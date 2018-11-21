//
//  Section.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/2/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol Section {
	associatedtype CellViewModel
	
	var title: String? { get }
	var cellViewModels: [CellViewModel] { get }
}
