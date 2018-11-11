//
//  Nibable.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/10/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol Nibable where Self: UIView {}

extension Nibable {
	static func nib(bundle: Bundle = Bundle.main) -> UINib {
		let className = String(describing: Self.self)
		return UINib(nibName: className, bundle: bundle)
	}
}
