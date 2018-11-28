//
//  Delegatable.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/28/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol Delegatable: class {
	associatedtype Delegate
	var delegate: Delegate? { get set }
}

extension Delegatable {
	func settingDelegate(to delegate: Delegate?) -> Self {
		self.delegate = delegate
		return self
	}
}
