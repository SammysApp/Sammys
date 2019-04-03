//
//  DatePickerViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/3/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

class DatePickerViewModel {
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        return formatter
    }()
    
    // MARK: - View Settable Properties
    var selectedDate = PickerDate.asap
    
    var isASAPAvailable = true {
        didSet { tableViewSectionModels.value = makeTableViewSectionModels() }
    }
    var minimumDate: Date? {
        didSet { tableViewSectionModels.value = makeTableViewSectionModels() }
    }
    var maximumDate: Date? {
        didSet { tableViewSectionModels.value = makeTableViewSectionModels() }
    }
    var minuteInterval = 1 {
        didSet { tableViewSectionModels.value = makeTableViewSectionModels() }
    }
    
    var dateTableViewCellViewModelActions = [UITableViewCellAction : UITableViewCellActionHandler]() {
        didSet { tableViewSectionModels.value = makeTableViewSectionModels() }
    }
    
    // MARK: - Dynamic Properties
    lazy var tableViewSectionModels = Dynamic(makeTableViewSectionModels())
    
    enum CellIdentifier: String {
        case tableViewCell
    }
    
    enum PickerDate: Equatable {
        case asap
        case date(Date)
    }
    
    private struct Constants {
        static let dateFormat = "h:mm a"
        static let dateTableViewCellViewModelHeight: Double = 60
        static let asapText = "ASAP"
    }
    
    // MARK: - Factory Methods
    private func makeDates() -> [Date] {
        guard let minimumDate = minimumDate,
            let maximumDate = maximumDate else { return [] }
        var date = minimumDate
        var dates = [Date]()
        while date <= maximumDate {
            dates.append(date)
            guard let newDate = Calendar.current.date(byAdding: .minute, value: minuteInterval, to: date) else { break }
            date = newDate
        }
        return dates
    }
    
    // MARK: - Section Model Methods
    private func makeTableViewSectionModels() -> [UITableViewSectionModel] {
        return [makeDatesTableViewSectionModel()]
    }
    
    private func makeDatesTableViewSectionModel() -> UITableViewSectionModel {
        var cellViewModels = makeDates().map { PickerDate.date($0) }.map(makeDateTableViewCellViewModel)
        if isASAPAvailable {
            cellViewModels.insert(makeDateTableViewCellViewModel(date: .asap), at: 0)
        }
        return UITableViewSectionModel(cellViewModels: cellViewModels)
    }
    
    // MARK: - Cell View Model Methods
    private func makeDateTableViewCellViewModel(date: PickerDate) -> DateTableViewCellViewModel {
        let text: String
        switch date {
        case .asap: text = Constants.asapText
        case .date(let date): text = dateFormatter.string(from: date)
        }
        return DateTableViewCellViewModel(
            identifier: CellIdentifier.tableViewCell.rawValue,
            height: .fixed(Constants.dateTableViewCellViewModelHeight),
            actions: dateTableViewCellViewModelActions,
            configurationData: .init(text: text, isSelected: selectedDate == date),
            selectionData: .init(date: date)
        )
    }
}

extension DatePickerViewModel {
    struct DateTableViewCellViewModel: UITableViewCellViewModel {
        let identifier: String
        let height: UITableViewCellViewModelHeight
        let actions: [UITableViewCellAction : UITableViewCellActionHandler]
        let configurationData: ConfigurationData
        let selectionData: SelectionData
        
        struct ConfigurationData {
            let text: String
            let isSelected: Bool
        }
        
        struct SelectionData {
            let date: PickerDate
        }
    }
}
