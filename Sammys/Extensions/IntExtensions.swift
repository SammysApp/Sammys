//
//  IntExtensions.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/12/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

extension Int {
    func toUSDUnits() -> Double {
        return Double(self)/100
    }
}
