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

// MARK: - Hex Initializer
extension UIColor {
    /// Initializes an instance with the given hex value.
    convenience init(hex: String) {
        let noHashString = hex.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: noHashString)
        scanner.charactersToBeSkipped = CharacterSet.symbols
        
        var hexInt: UInt32 = 0
        if (scanner.scanHexInt32(&hexInt)) {
            // Shift values all the way to left (each hex character is 4 bits) if neccessary. Mask to just include the respective RGB value by using the and operator.
            let red = (hexInt >> 16) & 0xFF
            let green = (hexInt >> 8) & 0xFF
            let blue = (hexInt) & 0xFF
            
            self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
        } else {
            fatalError("Bad hex value", file: #file, line: #line)
        }
    }
}
