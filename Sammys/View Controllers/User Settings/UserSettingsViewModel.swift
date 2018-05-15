//
//  UserSettingsViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/6/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

private struct UserSettingsSection {
    /// The tile of the section.
    let title: String?
    
    /// The cell view models in the section.
    let cellViewModels: [TableViewCellViewModel]
    
    init(title: String? = nil, cellViewModels: [TableViewCellViewModel]) {
        self.title = title
        self.cellViewModels = cellViewModels
    }
}

protocol UserSettingsViewModelDelegate {
    func didStartUpdatingName(in cell: TextFieldTableViewCell)
    func didStartUpdatingEmail(in cell: TextFieldTableViewCell)
    func didFinishUpdatingName(in cell: TextFieldTableViewCell)
    func didFinishUpdatingEmail(in cell: TextFieldTableViewCell)
    func didTapPassword()
}

class UserSettingsViewModel {
    private var user: User? {
        return UserDataStore.shared.user
    }
    
    var delegate: UserSettingsViewModelDelegate?
    
    private var sections: [UserSettingsSection] {
        guard let user = user else { return [] }
        return [
            UserSettingsSection(cellViewModels: [
                TextFieldTableViewCellViewModelFactory(height: 60, text: user.name, placeholder: "Name", textDidChange: nameTextDidChange).create(),
                TextFieldTableViewCellViewModelFactory(height: 60, text: user.email, placeholder: "Email", textDidChange: emailTextDidChange).create()
            ]),
            UserSettingsSection(cellViewModels: [
                UserSettingsButtonTableViewCellViewModelFactory(height: 60) { self.delegate?.didTapPassword() }.create()
            ])
        ]
    }
    
    var numberOfSections: Int {
        return sections.count
    }
    
    var userHasEmailAuthenticationProvider = false
    
    init() {
        if let user = user {
            UserAPIClient.userHasEmailAuthenticationProvider(user) { self.userHasEmailAuthenticationProvider = $0 }
        }
    }
    
    func numberOfRows(inSection section: Int) -> Int {
        return sections[section].cellViewModels.count
    }
    
    func cellViewModel(for indexPath: IndexPath) -> TableViewCellViewModel {
        return sections[indexPath.section].cellViewModels[indexPath.row]
    }
    
    func nameTextDidChange(with name: String, in cell: TextFieldTableViewCell) {
        delegate?.didStartUpdatingName(in: cell)
        UserAPIClient.updateCurrentUserName(name) { error in self.delegate?.didFinishUpdatingName(in: cell)
        }
    }
    
    func emailTextDidChange(with email: String, in cell: TextFieldTableViewCell) {
        self.delegate?.didStartUpdatingEmail(in: cell)
        UserAPIClient.updateCurrentUserEmail(email) { error in self.delegate?.didFinishUpdatingEmail(in: cell)
        }
    }
    
    func updatePassword(_ password: String, completed: @escaping (Bool) -> Void) {
        UserAPIClient.updateCurrentUserPassword(password) { error in
            completed(error != nil)
        }
    }
    
    func linkPassword(_ password: String, completed: @escaping (Bool) -> Void) {
        UserAPIClient.linkEmailAuthProviderToCurrentUser(withPassword: password) { error in
            if error == nil, let user = self.user {
                UserAPIClient.set(.email, for: user)
            }
            completed(error != nil)
        }
    }
    
    func reauthenticate(withEmail email: String, password: String, completed: ((Error?) -> Void)? = nil) {
        UserAPIClient.reauthenticate(withEmail: email, password: password, completed: completed)
    }
}
