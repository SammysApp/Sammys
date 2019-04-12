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
        didSet { updateTableViewSectionModels() }
    }
    private var buttonsTableViewSectionModel: UITableViewSectionModel? {
        didSet { updateTableViewSectionModels() }
    }
    
    // MARK: - View Settable Properties
    /// Required to be non-`nil`. Calling `beginDownloads()`
    /// will attempt to get the current user and set this property.
    var userID: User.ID?
    
    var userDetailTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]()
    
    var buttonTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]() {
        didSet { updateButtonsTableViewSectionModel() }
    }
    
    var errorHandler: ((Error) -> Void) = { _ in }
    
    // MARK: - Dynamic Properties
    private(set) lazy var tableViewSectionModels = Dynamic(makeTableViewSectionModels())
    
    enum CellIdentifier: String {
        case tableViewCell
    }
    
    private struct Constants {
        static let userDetailTableViewCellModelNameTitle = "Name"
        static let userDetailTableViewCellModelEmailTitle = "Email"
        
        static let userDetailTableViewCellViewModelHeight = Double(60)
        
        static let logOutButtonTitle = "Log Out"
        
        static let buttonTableViewCellViewModelHeight = Double(60)
    }
    
    init(httpClient: HTTPClient = URLSession.shared,
         keyValueStore: KeyValueStore = UserDefaults.standard,
         userAuthManager: UserAuthManager = Auth.auth()) {
        self.httpClient = httpClient
        self.keyValueStore = keyValueStore
        self.userAuthManager = userAuthManager
    }
    
    // MARK: - Setup Methods
    private func setUp(for user: User) {
        userDetailsTableViewSectionModel = makeUserDetailsTableViewSectionModel(cellModels: makeUserDetailTableViewCellModels(user: user))
    }
    
    private func updateTableViewSectionModels() {
        tableViewSectionModels.value = makeTableViewSectionModels()
    }
    
    private func updateButtonsTableViewSectionModel() {
        buttonsTableViewSectionModel = makeButtonsTableViewSectionModel(cellModels: makeButtonTableViewCellModels())
    }
    
    // MARK: - Methods
    func logOut() throws {
        try userAuthManager.signOutCurrentUser()
        keyValueStore.set(Optional<String>(nil), forKey: KeyValueStoreKeys.currentOutstandingOrderID)
    }
    
    // MARK: - Download Methods
    func beginDownloads() {
        beginUserDownload()
            .catch { self.errorHandler($0) }
    }
    
    private func beginUserDownload() -> Promise<Void> {
        return makeUserDownload().done(setUp)
    }
    
    private func makeUserDownload() -> Promise<User> {
        if userID == nil {
            return userAuthManager.getCurrentUserIDToken()
                .then { self.getTokenUser(token: $0) }
                .get { self.userID = $0.id }
        } else {
            return userAuthManager.getCurrentUserIDToken()
                .then { self.getUser(token: $0) }
        }
    }
    
    private func getUser(token: JWT) -> Promise<User> {
        return httpClient.send(apiURLRequestFactory.makeGetUserRequest(id: userID ?? preconditionFailure(), token: token)).validate()
            .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode(User.self, from: $0.data) }
    }
    
    private func getTokenUser(token: JWT) -> Promise<User> {
        return httpClient.send(apiURLRequestFactory.makeGetTokenUserRequest(token: token)).validate()
            .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode(User.self, from: $0.data) }
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
    
    // MARK: - Cell Model Methods
    private func makeUserDetailTableViewCellModels(user: User) -> [UserDetailTableViewCellModel] {
        return [
            UserDetailTableViewCellModel(title: Constants.userDetailTableViewCellModelNameTitle, text: user.firstName + " " + user.lastName),
            UserDetailTableViewCellModel(title: Constants.userDetailTableViewCellModelEmailTitle, text: user.email)
        ]
    }
    
    private func makeButtonTableViewCellModels() -> [ButtonTableViewCellModel] {
        return Button.allCases.map(ButtonTableViewCellModel.init)
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
            case .logOut: return Constants.logOutButtonTitle
            }
        }
    }
    
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
