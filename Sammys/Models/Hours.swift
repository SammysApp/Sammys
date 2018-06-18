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
    let doesCloseNextDay: Bool?
}

struct DateHours {
    let open: Date
    let close: Date
}

extension Hours {
    func dateHours(for date: Date) -> DateHours? {
        guard Calendar.current.component(.weekday, from: date) == day,
            let open = Calendar.current.date(bySettingHour: self.open, minute: 0, second: 0, of: date),
            var close = Calendar.current.date(bySettingHour: self.close, minute: 0, second: 0, of: date) else { return nil }
        if doesCloseNextDay == true {
            guard let closeNextDay = Calendar.current.date(byAdding: .day, value: 1, to: close) else { return nil }
            close = closeNextDay
        }
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
