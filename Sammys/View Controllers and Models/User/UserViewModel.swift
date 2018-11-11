//
//  UserViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/30/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import Stripe

protocol UserViewModelDelegate {
    /// Called by delegate if user changed.
    var userDidChange: () -> Void { get }
    var didSelectOrders: () -> Void { get }
    var didSelectLogOut: () -> Void { get }
}

/// A section in the user view.
private struct UserSection {
    /// The tile of the section.
    let title: String?
    
    /// The cell view models in the section.
    let cellViewModels: [TableViewCellViewModel]
    
    init(title: String? = nil, cellViewModels: [TableViewCellViewModel]) {
        self.title = title
        self.cellViewModels = cellViewModels
    }
}

class UserViewModel {
    var delegate: UserViewModelDelegate?
    let id = UUID().uuidString
    
    private var userState: Variable<UserState>?
    private var user: User?
    
    /// The sections to populate the user view with.
    private var sections: [UserSection] {
        guard let user = user else { return [] }
//        return [
//            UserSection(title: "My Info", cellViewModels: [
//                DetailTableViewCellViewModelFactory(height: 60, titleText: "Name", detailText: user.name).create(),
//                DetailTableViewCellViewModelFactory(height: 60, titleText: "Email", detailText: user.email).create()
//            ]),
//            UserSection(cellViewModels: [
//                ButtonTableViewCellViewModelFactory(height: 60, buttonText: "My Orders", selectionCommand: UserButtonTableViewCellSelectionCommand(didSelect: { self.delegate?.didSelectOrders() })).create(),
//                ButtonTableViewCellViewModelFactory(height: 60, buttonText: "Log Out", selectionCommand: UserButtonTableViewCellSelectionCommand(didSelect: { self.delegate?.didSelectLogOut() })).create()
//            ])
//        ]
		return []
    }
    
    var needsUser: Bool {
        return user == nil
    }
    
    var numberOfSections: Int {
        return sections.count
    }
    
    init() {
        userState = UserAPIManager.observableUserState()
            .adding(UpdateClosure<UserState>(id: id) { userState in
            self.delegate?.userDidChange()
        })
    }
    
    func numberOfRows(in section: Int) -> Int {
        return sections[section].cellViewModels.count
    }
    
    func cellViewModel(for indexPath: IndexPath) -> TableViewCellViewModel {
        return sections[indexPath.section].cellViewModels[indexPath.row]
    }
    
    func sectionTitle(for section: Int) -> String? {
        return sections[section].title
    }
}
