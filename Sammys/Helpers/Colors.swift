//
//  Colors.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/13/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

import UIKit

// MARK: - Custom Colors
enum ColorName: String {
    case snow = "Snow"
    case mocha = "Mocha"
    case flora = "Flora"
}

extension UIColor {
    static var snow: UIColor {
        return ColorFactory.create(.snow)
    }
    
    /// A warm coffee-ish brown. (R: 148, G: 82, B: 0).
    static var mocha: UIColor {
        return ColorFactory.create(.mocha)
    }
    
    static var flora: UIColor {
        return ColorFactory.create(.flora)
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
