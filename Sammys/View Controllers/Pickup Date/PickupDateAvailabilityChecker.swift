//
//  PickupDateAvailabilityChecker.swift
//  Sammys
//
//  Created by Natanel Niazoff on 6/26/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct PickupDateAvailabilityCheckerConfiguration {
    var startDate: Date
    var hours: [Hours]
    var amountOfFutureDays: Int
    var timePickerInterval: Int
}

struct PickupDateAvailabilityChecker {
    private var configuration: PickupDateAvailabilityCheckerConfiguration
    
    var availablePickupDayDates: [Date]? {
        var dates = [Date]()
        for day in 0...configuration.amountOfFutureDays {
            guard let date = Calendar.current.date(byAdding: .day, value: day, to: configuration.startDate) else { continue }
            if let availableDates = availablePickupTimeDates(for: date),
                !availableDates.isEmpty {
                dates.append(date)
            }
        }
        return dates
    }
    
    init(_ configuration: PickupDateAvailabilityCheckerConfiguration) {
        self.configuration = configuration
    }
    
    func availablePickupTimeDates(for date: Date) -> [Date]? {
        guard let dateHours = configuration.hours.dateHours(for: date) else { return nil }
        var currentDate = dateHours.open
        var dates = [Date]()
        while currentDate <= dateHours.close {
            if currentDate > configuration.startDate {
                dates.append(currentDate)
            }
            guard let newDate = Calendar.current.date(byAdding: .minute, value: configuration.timePickerInterval, to: currentDate) else { return nil }
            currentDate = newDate
        }
        return dates
    }
}
