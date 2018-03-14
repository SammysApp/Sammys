//
//  Colors.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/13/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

import UIKit

enum ColorName: String {
    case mocha = "Mocha"
}

extension UIColor {
    /// A warm coffee-ish brown. (R: 148, G: 82, B: 0).
    static var mocha: UIColor {
        return ColorFactory.create(.mocha)
    }
}

struct ColorFactory {
    static func create(_ colorName: ColorName) -> UIColor {
        guard let color = UIColor(named: colorName.rawValue) else {
            fatalError("\(colorName) color not found", file: #file, line: #line)
        }
        return color
    }
}
