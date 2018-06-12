//
//  AppEnvironment.swift
//  Sammys
//
//  Created by Natanel Niazoff on 6/12/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum AppEnvironment {
    case debug, release, family
    
    var isLive: Bool {
        return self == .release
    }
}
