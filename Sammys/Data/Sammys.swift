//
//  Sammys.swift
//  Sammys
//
//  Created by Natanel Niazoff on 7/12/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Sammys {
    private struct Constants {
        static let timeZoneIdentifier = "America/New_York"
    }
    
    static var calendar: Calendar {
        guard let timeZone = TimeZone(identifier: Constants.timeZoneIdentifier) else { fatalError() }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar
    }
}
