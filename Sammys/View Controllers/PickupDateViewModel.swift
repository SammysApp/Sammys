//
//  PickupDateViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 6/15/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

private struct Component {
    let key: PickerViewComponentKey
    let rows: [Row]
}

private struct Row {
    let date: Date
}

private enum PickerViewComponentKey: Int {
    case day, time
    
    var dateFormat: String {
        switch self {
        case .day: return "E, MMM d"
        case .time: return "h:mm a"
        }
    }
}

enum PickupDate {
    case asap
    case future(Date)
}

protocol PickupDateViewModelDelegate: class {
    func needsUIUpdate()
    func datePickerViewNeedsUpdate()
    func datePickerViewNeedsUpdate(forComponent component: Int)
    func datePickerSelectedRow(inComponent component: Int) -> Int
    func didSelect(_ date: Date)
}

class PickupDateViewModel {
    var startDate = Date()
    var wantsPickupASAP = true {
        didSet {
            delegate?.needsUIUpdate()
        }
    }
    private var selectedTimeDate: Date?
    private lazy var selectedDayDate = availablePickupDayDates?.first
    private var pickupDate: PickupDate? {
        if wantsPickupASAP { return .asap }
        else if let date = selectedTimeDate { return .future(date) }
        return nil
    }
    var componentsCount: Int {
        return components.count
    }
    
    var amountOfFutureDays = 7
    var timePickerInterval = 10
    
    weak var delegate: PickupDateViewModelDelegate?
    
    private var hours: [Hours]? {
        return SammysDataStore.shared.hours
    }
    
    private var availablePickupDayDates: [Date]?
    
    var dateLabelText: String? {
        if let pickupDate = pickupDate {
            switch pickupDate {
            case .asap: return "ASAP"
            case .future(let date):
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE, MMM d\nh:mm a"
                return formatter.string(from: date)
            }
        }
        return nil
    }
    
    var shouldHidePickupASAPButton: Bool {
        return wantsPickupASAP
    }
    
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
        var dates = [startDate]
        for day in 1...amountOfFutureDays {
            guard let nextDate = Calendar.current.date(byAdding: .day, value: day, to: startDate) else { continue }
            dates.append(nextDate)
        }
        availablePickupDayDates = dates
    }
    
    private func availablePickupTimeDates(for date: Date) -> [Date]? {
        guard let dateHours = hours?.dateHours(for: date) else { return nil }
        var currentDate = dateHours.open
        var dates = [Date]()
        while currentDate <= dateHours.close {
            if currentDate > startDate {
                dates.append(currentDate)
            }
            guard let newDate = Calendar.current.date(byAdding: .minute, value: timePickerInterval, to: currentDate) else { return nil }
            currentDate = newDate
        }
        return dates
    }
    
    private var components: [Component] {
        var components = [Component]()
        if let dayRows = availablePickupDayDates?.map({ Row(date: $0) }) {
            components.append(Component(key: .day, rows: dayRows))
        }
        if let date = selectedDayDate,
            let timeRows = availablePickupTimeDates(for: date)?.map({ Row(date: $0) }) {
            components.append(Component(key: .time, rows: timeRows))
        }
        return components
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
        guard let pickerViewComponentKey = PickerViewComponentKey(rawValue: component) else { return }
        // Once selects anything in picker view, doesn't want pickup ASAP.
        wantsPickupASAP = false
        let date = components[component].rows[row].date
        switch pickerViewComponentKey {
        case .day:
            selectedDayDate = date
            let timeComponent = PickerViewComponentKey.time.rawValue
            delegate?.datePickerViewNeedsUpdate(forComponent: timeComponent)
            if let selectedTimeRow = delegate?.datePickerSelectedRow(inComponent: timeComponent) {
                selectedTimeDate = components[timeComponent].rows[selectedTimeRow].date
            }
            delegate?.needsUIUpdate()
        case .time:
            selectedTimeDate = date
            delegate?.didSelect(date)
            delegate?.needsUIUpdate()
        }
    }
    
    func resetComponents() {
        selectedDayDate = availablePickupDayDates?.first
        delegate?.datePickerViewNeedsUpdate()
    }
}
