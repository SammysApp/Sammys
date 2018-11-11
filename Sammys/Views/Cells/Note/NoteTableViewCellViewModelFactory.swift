//
//  NoteTableViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 6/20/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol TableViewCellIdentifier {
    func register(for tableView: UITableView)
}

protocol NoteTableViewCellIdentifier: TableViewCellIdentifier, RawRepresentable where RawValue == String { }

enum DefaultNoteTableViewCellIdentifier: String, NoteTableViewCellIdentifier {
    case noteCell
}

extension NoteTableViewCellIdentifier {
    func register(for tableView: UITableView) {
        tableView.register(NoteTableViewCell.self, forCellReuseIdentifier: rawValue)
    }
}

struct NoteConfigurationParameters {
    var textViewDidChange: ((UITextView) -> Void)?
}

protocol NoteTableViewCellConfigurationCommand: TableViewCellCommand {
    func perform(cell: NoteTableViewCell)
}

extension NoteTableViewCellConfigurationCommand {
    func perform(cell: UITableViewCell?) {
        guard let cell = cell as? NoteTableViewCell else { return }
        perform(cell: cell)
    }
}

struct NoteTableViewCellViewModelFactory<T: NoteTableViewCellIdentifier>/*: TableViewCellViewModelFactory*/ {
    let identifier: T
    let height: CGFloat
    let configurationCommand: NoteTableViewCellConfigurationCommand
    
//    func create() -> TableViewCellViewModel {
//        return DefaultTableViewCellViewModel(identifier: identifier.rawValue, height: height, isSelectable: false, isEditable: false, commands: [.configuration: configurationCommand])
//    }
}
