//
//  UserViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/22/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit
import FirebaseAuth

class UserViewModel {
    private let apiURLRequestFactory = APIURLRequestFactory()
    
    // MARK: - Dependencies
    var httpClient: HTTPClient
    var keyValueStore: KeyValueStore
    var userAuthManager: UserAuthManager
    
    // MARK: - Section Model Properties
    private var userDetailsTableViewSectionModel: UITableViewSectionModel? {
        didSet { tableViewSectionModels.value = makeTableViewSectionModels() }
    }
    private var buttonsTableViewSectionModel: UITableViewSectionModel? {
        didSet { tableViewSectionModels.value = makeTableViewSectionModels() }
    }
    
    // MARK: - View Settable Properties
    /// Required to be non-`nil`. Calling `beginUserDownload()` will
    /// try getting the current user and setting this property.
    var userID: User.ID?
    
    var userDetailTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]()
    var buttonTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]() {
        didSet { update() }
    }
    var errorHandler: ((Error) -> Void)?
    
    // MARK: - Dynamic Properties
    let tableViewSectionModels = Dynamic([UITableViewSectionModel]())
    let isUserDownloading = Dynamic(false)
    
    enum CellIdentifier: String {
        case tableViewCell
    }
    
    private struct Constants {
        static let userDetailTableViewCellViewModelHeight: Double = 60
        static let buttonTableViewCellViewModelHeight: Double = 60
    }
    
    init(httpClient: HTTPClient = URLSession.shared,
         keyValueStore: KeyValueStore = UserDefaults.standard,
         userAuthManager: UserAuthManager = Auth.auth()) {
        self.httpClient = httpClient
        self.keyValueStore = keyValueStore
        self.userAuthManager = userAuthManager
    }
    
    // MARK: - Setup Methods
    func update() {
        buttonsTableViewSectionModel = makeButtonsTableViewSectionModel(cellModels: makeButtonTableViewCellModels())
    }
    
    // MARK: - Download Methods
    func beginUserDownload() {
        isUserDownloading.value = true
        let userPromise: Promise<User>
        if userID == nil {
            userPromise = userAuthManager.getCurrentUserIDToken()
                .then { self.getTokenUser(token: $0) }
                .get { self.userID = $0.id }
        } else {
            userPromise = userAuthManager.getCurrentUserIDToken()
                .then { self.getUser(token: $0) }
        }
        userPromise.ensure { self.isUserDownloading.value = false }.done { user in
                self.userDetailsTableViewSectionModel = self.makeUserDetailsTableViewSectionModel(cellModels: self.makeUserDetailTableViewCellModels(user: user))
            }.catch { self.errorHandler?($0) }
    }
    
    private func getUser(token: JWT) -> Promise<User> {
        return httpClient.send(apiURLRequestFactory.makeGetUserRequest(id: userID ?? preconditionFailure(), token: token)).validate()
            .map { try JSONDecoder().decode(User.self, from: $0.data) }
    }
    
    private func getTokenUser(token: JWT) -> Promise<User> {
        return httpClient.send(apiURLRequestFactory.makeGetTokenUserRequest(token: token)).validate()
            .map { try JSONDecoder().decode(User.self, from: $0.data) }
    }
    
    func logOut() throws {
        try userAuthManager.signOutCurrentUser()
        keyValueStore.set(Optional<String>(nil), forKey: KeyValueStoreKeys.currentOutstandingOrderID)
    }
    
    // MARK: - Factory Methods
    private func makeUserDetailTableViewCellModels(user: User) -> [UserDetailTableViewCellModel] {
        return [
            UserDetailTableViewCellModel(title: "Name", text: user.firstName + " " + user.lastName),
            UserDetailTableViewCellModel(title: "Email", text: user.email)
        ]
    }
    
    private func makeButtonTableViewCellModels() -> [ButtonTableViewCellModel] {
        return Button.allCases.map(ButtonTableViewCellModel.init)
    }
    
    // MARK: - Section Model Methods
    private func makeTableViewSectionModels() -> [UITableViewSectionModel] {
        var sectionModels = [UITableViewSectionModel]()
        if let userDetailsModel = userDetailsTableViewSectionModel { sectionModels.append(userDetailsModel) }
        if let buttonsModel = buttonsTableViewSectionModel { sectionModels.append(buttonsModel) }
        return sectionModels
    }
    
    private func makeUserDetailsTableViewSectionModel(cellModels: [UserDetailTableViewCellModel]) -> UITableViewSectionModel {
        return UITableViewSectionModel(cellViewModels: cellModels.map(makeUserDetailTableViewCellViewModel))
    }
    
    private func makeButtonsTableViewSectionModel(cellModels: [ButtonTableViewCellModel]) -> UITableViewSectionModel {
        return UITableViewSectionModel(cellViewModels: cellModels.map(makeButtonTableViewCellViewModel))
    }
    
    // MARK: - Cell View Model Methods
    private func makeUserDetailTableViewCellViewModel(cellModel: UserDetailTableViewCellModel) -> UserDetailTableViewCellViewModel {
        return UserDetailTableViewCellViewModel(
            identifier: CellIdentifier.tableViewCell.rawValue,
            height: .fixed(Constants.userDetailTableViewCellViewModelHeight),
            actions: userDetailTableViewCellViewModelActions,
            configurationData: .init(text: cellModel.text)
        )
    }
    
    private func makeButtonTableViewCellViewModel(cellModel: ButtonTableViewCellModel) -> ButtonTableViewCellViewModel {
        return ButtonTableViewCellViewModel(
            identifier: CellIdentifier.tableViewCell.rawValue,
            height: .fixed(Constants.buttonTableViewCellViewModelHeight),
            actions: buttonTableViewCellViewModelActions,
            configurationData: .init(title: cellModel.button.title),
            selectionData: .init(button: cellModel.button)
        )
    }
}

private extension UserViewModel {
    struct UserDetailTableViewCellModel {
        let title: String
        let text: String
    }
}

extension UserViewModel {
    enum Button: CaseIterable {
        case logOut
        
        var title: String {
            switch self {
            case .logOut: return "Log Out"
            }
        }
    }
}

private extension UserViewModel {
    struct ButtonTableViewCellModel {
        let button: Button
    }
}

extension UserViewModel {
    struct UserDetailTableViewCellViewModel: UITableViewCellViewModel {
        let identifier: String
        let height: UITableViewCellViewModelHeight
        let actions: [UITableViewCellAction: UITableViewCellActionHandler]
        let configurationData: ConfigurationData
        
        struct ConfigurationData {
            let text: String
        }
    }
}

extension UserViewModel {
    struct ButtonTableViewCellViewModel: UITableViewCellViewModel {
        let identifier: String
        let height: UITableViewCellViewModelHeight
        let actions: [UITableViewCellAction : UITableViewCellActionHandler]
        let configurationData: ConfigurationData
        let selectionData: SelectionData
        
        struct ConfigurationData {
            let title: String
        }
        
        struct SelectionData {
            let button: Button
        }
    }
}
