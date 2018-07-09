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
    func didSelect(_ pickupDate: PickupDate)
}

class PickupDateViewModel {
    weak var delegate: PickupDateViewModelDelegate?
    
    private var sammys: SammysDataStore {
        return SammysDataStore.shared
    }
    
    private var hours = [Hours]()
    
    var isPickupASAPAvailable: Bool {
        return pickupDateAvailabilityChecker.isPickupASAPAvailable(for: Date())
    }
    
    var wantsPickupASAP = true {
        didSet {
            if wantsPickupASAP {
                delegate?.didSelect(.asap)
            }
            delegate?.needsUIUpdate()
        }
    }
    
    var startDate = Date() {
        didSet {
            delegate?.datePickerViewNeedsUpdate()
        }
    }
    
    private var pickupDateAvailabilityCheckerConfiguration: PickupDateAvailabilityCheckerConfiguration {
        return PickupDateAvailabilityCheckerConfiguration(startDate: startDate, hours: hours, amountOfFutureDays: 7, timePickerInterval: 10)
    }
    
    private var pickupDateAvailabilityChecker: PickupDateAvailabilityChecker {
        return PickupDateAvailabilityChecker(pickupDateAvailabilityCheckerConfiguration)
    }
    
    private var availablePickupDayDates: [Date]? {
        return pickupDateAvailabilityChecker.availablePickupDayDates
    }
    
    private var selectedTimeDate: Date?
    
    private lazy var selectedDayDate = availablePickupDayDates?.first
    
    private var pickupDate: PickupDate? {
        if wantsPickupASAP && isPickupASAPAvailable { return .asap }
        else if let date = selectedTimeDate { return .future(date) }
        return nil
    }
    
    var dateLabelText: String? {
        if let pickupDate = pickupDate {
            switch pickupDate {
            case .asap: return "ASAP"
            case .future(let date):
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE, MMM d\nh:mm a"
                return formatter.string(from: date)
            }
        } else if !isPickupASAPAvailable {
            return "ASAP Unavailable"
        }
        return nil
    }
    
    var shouldHidePickupASAPButton: Bool {
        return wantsPickupASAP || !isPickupASAPAvailable
    }
    
    var componentsCount: Int {
        return components.count
    }
    
    var numberOfComponents: Int {
        // Return 1 if empty to keep selection indicator visible.
        return components.isEmpty ? 1 : components.count
    }
    
    init() {
        setupHours()
    }
    
    func setupHours() {
        guard let hours = sammys.hours else {
            sammys.setHours(didComplete: handleDidSetupHours)
            return
        }
        handleDidSetupHours(hours)
    }
    
    func handleDidSetupHours(_ hours: [Hours]) {
        self.hours = hours
        selectedDayDate = availablePickupDayDates?.first
        delegate?.datePickerViewNeedsUpdate()
    }
    
    private var components: [Component] {
        var components = [Component]()
        if let dayRows = availablePickupDayDates?.map({ Row(date: $0) }) {
            components.append(Component(key: .day, rows: dayRows))
        }
        if let date = selectedDayDate,
            let timeRows = pickupDateAvailabilityChecker.availablePickupTimeDates(for: date)?.map({ Row(date: $0) }) {
            components.append(Component(key: .time, rows: timeRows))
        }
        return components
    }
    
    func numberOfRows(inComponent component: Int) -> Int {
        return components[safe: component]?.rows.count ?? 0
    }
    
    func title(forRow row: Int, inComponent component: Int) -> String? {
        let formatter = DateFormatter()
        guard let component = components[safe: component] else { return nil }
        formatter.dateFormat = component.key.dateFormat
        return formatter.string(from: component.rows[row].date)
    }
    
    func handleDidSelectRow(_ row: Int, inComponent component: Int) {
        guard let pickerViewComponentKey = PickerViewComponentKey(rawValue: component) else { return }
        // Once selects anything in picker view, doesn't want pickup ASAP.
        wantsPickupASAP = false
        guard let date = components[safe: component]?.rows[safe: row]?.date else { return }
        switch pickerViewComponentKey {
        case .day:
            selectedDayDate = date
            let timeComponent = PickerViewComponentKey.time.rawValue
            delegate?.datePickerViewNeedsUpdate(forComponent: timeComponent)
            if let selectedTimeRow = delegate?.datePickerSelectedRow(inComponent: timeComponent) {
                selectedTimeDate = components[safe: timeComponent]?.rows[safe: selectedTimeRow]?.date
            }
            if let pickupDate = pickupDate { delegate?.didSelect(pickupDate) }
            delegate?.needsUIUpdate()
        case .time:
            selectedTimeDate = date
            if let pickupDate = pickupDate { delegate?.didSelect(pickupDate) }
            delegate?.needsUIUpdate()
        }
    }
    
    func resetComponents() {
        selectedDayDate = availablePickupDayDates?.first
        delegate?.datePickerViewNeedsUpdate()
    }
}
