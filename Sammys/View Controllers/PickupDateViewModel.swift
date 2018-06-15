//
//  PickupDateViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 6/15/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Component {
    let key: PickerViewComponentKey
    let rows: [Row]
}

struct Row {
    let date: Date
}

enum PickerViewComponentKey: Int {
    case day, time
    
    var dateFormat: String {
        switch self {
        case .day: return "E, MMM d"
        case .time: return "h:mm a"
        }
    }
}

protocol PickupDateViewModelDelegate: class {
    func datePickerViewNeedsUpdate()
    func datePickerViewNeedsUpdate(for component: Int)
}

class PickupDateViewModel {
    var startDate = Date()
    lazy var selectedDayDate = availablePickupDayDates.first!
    var amountOfFutureDays = 7
    var timePickerInterval = 10
    
    weak var delegate: PickupDateViewModelDelegate?
    
    private var hours: [Hours]? {
        return SammysDataStore.shared.hours
    }
    
    private var availablePickupDayDates = [Date]()
    
    var numberOfComponents: Int {
        return components.count
    }
    
    init() {
        setupAvailablePickupDayDates()
        SammysDataStore.shared.setHours { hours in
            self.delegate?.datePickerViewNeedsUpdate()
        }
    }
    
    private func setupAvailablePickupDayDates() {
        let currentDate = startDate
        var dates = [currentDate]
        for day in 1...amountOfFutureDays {
            guard let nextDate = Calendar.current.date(byAdding: .day, value: day, to: currentDate) else { continue }
            dates.append(nextDate)
        }
        availablePickupDayDates = dates
    }
    
    private func availablePickupTimeDates(for date: Date) -> [Date] {
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
    
    private var components: [Component] {
        let dayRows = availablePickupDayDates.map { Row(date: $0) }
        let dayComponent = Component(key: .day, rows: dayRows)
        let timeRows = availablePickupTimeDates(for: selectedDayDate).map { Row(date: $0) }
        let timeComponent = Component(key: .time, rows: timeRows)
        return [dayComponent, timeComponent]
    }
    
    func numberOfRows(inComponent component: Int) -> Int {
        return components[component].rows.count
    }
    
    func title(forRow row: Int, inComponent component: Int) -> String {
        let formatter = DateFormatter()
        let component = components[component]
        formatter.dateFormat = component.key.dateFormat
        return formatter.string(from: component.rows[row].date)
    }
    
    func handleDidSelectRow(_ row: Int, inComponent component: Int) {
        if PickerViewComponentKey(rawValue: component) == .day {
            selectedDayDate = components[component].rows[row].date
            delegate?.datePickerViewNeedsUpdate(for: PickerViewComponentKey.time.rawValue)
        }
    }
}
