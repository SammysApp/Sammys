//
//  Hours.swift
//  Sammys
//
//  Created by Natanel Niazoff on 6/14/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Hours: Codable {
    let day: Int
    let open: Int
    let close: Int
}

struct DateHours {
    let open: Date
    let close: Date
}

extension Hours {
    func dateHours(for date: Date) -> DateHours? {
        guard Calendar.current.component(.weekday, from: date) == day,
            let open = Calendar.current.date(bySettingHour: self.open, minute: 0, second: 0, of: date),
            let close = Calendar.current.date(bySettingHour: self.close, minute: 0, second: 0, of: date) else { return nil }
        return DateHours(open: open, close: close)
    }
}

extension Array where Element == Hours {
    func dateHours(for date: Date) -> DateHours? {
        let dateWeekday = Calendar.current.component(.weekday, from: date)
        let hours = first { $0.day == dateWeekday }
        return hours?.dateHours(for: date)
    }
}
