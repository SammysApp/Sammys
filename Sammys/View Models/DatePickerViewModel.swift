//
//  DatePickerViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/3/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

class DatePickerViewModel {
    private let calendar = Calendar.current
    
    private var dateTableViewCellViewModelTextDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateTableViewCellViewModelTextDateFormat
        return formatter
    }()
    
    // MARK: - View Settable Properties
    var selectedDate = PickerDate.asap {
        didSet { updateTableViewSectionModels() }
    }
    
    var isASAPAvailable = true {
        didSet { updateTableViewSectionModels() }
    }
    var minuteInterval = 1 {
        didSet { updateTableViewSectionModels() }
    }
    var minimumDate: Date? {
        didSet { updateTableViewSectionModels() }
    }
    var maximumDate: Date? {
        didSet { updateTableViewSectionModels() }
    }
    
    var dateTableViewCellViewModelActions = [UITableViewCellAction : UITableViewCellActionHandler]() {
        didSet { updateTableViewSectionModels() }
    }
    
    // MARK: - Dynamic Properties
    private(set) lazy var tableViewSectionModels = Dynamic(makeTableViewSectionModels())
    
    enum PickerDate: Equatable {
        case asap
        case date(Date)
    }
    
    enum CellIdentifier: String {
        case tableViewCell
    }
    
    private struct Constants {
        static let dateTableViewCellViewModelTextDateFormat = "h:mm a"
        static let dateTableViewCellViewModelASAPText = "ASAP"
        static let dateTableViewCellViewModelHeight = Double(60)
    }
    
    // MARK: - Setup Methods
    private func updateTableViewSectionModels() {
        tableViewSectionModels.value = makeTableViewSectionModels()
    }
    
    // MARK: - Factory Methods
    private func makeDates() -> [Date] {
        guard let minimumDate = minimumDate,
            let maximumDate = maximumDate else { return [] }
        var date = minimumDate
        var dates = [Date]()
        while date <= maximumDate {
            dates.append(date)
            guard let newDate = calendar.date(byAdding: .minute, value: minuteInterval, to: date) else { break }
            date = newDate
        }
        return dates
    }
    
    // MARK: - Section Model Methods
    private func makeDatesTableViewSectionModel() -> UITableViewSectionModel {
        var cellViewModels = makeDates().map(PickerDate.date).map(makeDateTableViewCellViewModel)
        if isASAPAvailable {
            cellViewModels.insert(makeDateTableViewCellViewModel(date: .asap), at: 0)
        }
        return UITableViewSectionModel(cellViewModels: cellViewModels)
    }
    
    private func makeTableViewSectionModels() -> [UITableViewSectionModel] {
        return [makeDatesTableViewSectionModel()]
    }
    
    // MARK: - Cell View Model Methods
    private func makeDateTableViewCellViewModel(date: PickerDate) -> DateTableViewCellViewModel {
        let text: String
        switch date {
        case .asap: text = Constants.dateTableViewCellViewModelASAPText
        case .date(let date): text = dateTableViewCellViewModelTextDateFormatter.string(from: date)
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
        let actions: [UITableViewCellAction: UITableViewCellActionHandler]
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
