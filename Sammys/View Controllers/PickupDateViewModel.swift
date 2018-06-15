//
//  PickupDateViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 6/15/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum PickerViewKey {
    case day, time(Date)
}

class PickupDateViewModel {
    var amountOfFutureDays = 7
    var timePickerInterval = 10
    
    private var hours: [Hours]? {
        return SammysDataStore.shared.hours
    }
    
    private var availablePickupDates: [Date] {
        let currentDate = Date()
        var dates = [currentDate]
        for day in 1...amountOfFutureDays {
            guard let nextDate = Calendar.current.date(byAdding: .day, value: day, to: currentDate) else { continue }
            dates.append(nextDate)
        }
        return dates
    }
    
    init() {
        SammysDataStore.shared.setHours { hours in
            
        }
    }
    
    private func availablePickupDates(for date: Date) -> [Date] {
        guard let dateHours = hours?.dateHours(for: date) else { return [] }
        var startDate = dateHours.open
        var dates = [startDate]
        while startDate < dateHours.close {
            guard let newDate = Calendar.current.date(byAdding: .minute, value: timePickerInterval, to: startDate) else { continue }
            startDate = newDate
            dates.append(startDate)
        }
        return dates
    }
    
    func numberOfComponents(for pickerViewKey: PickerViewKey) -> Int {
        return 1
    }
    
    func numberOfRows(inComponent component: Int, for pickerViewKey: PickerViewKey) -> Int {
        switch pickerViewKey {
        case .day: return availablePickupDates.count
        case .time(let date): return availablePickupDates(for: date).count
        }
    }
    
    func title(forRow row: Int, inComponent component: Int, for pickerViewKey: PickerViewKey) -> String {
        let formatter = DateFormatter()
        switch pickerViewKey {
        case .day:
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: availablePickupDates[row])
        case .time(let date):
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: availablePickupDates(for: date)[row])
        }
    }
}
