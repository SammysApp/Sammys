//
//  UserAuthViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/19/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit
import FirebaseAuth

class UserAuthViewModel {
    private let apiURLRequestFactory = APIURLRequestFactory()
    
    private var userData = UserData()
    
    // MARK: - Cell Model Properties
    private let newUserTextFieldTableViewCellModels = [
        TextFieldTableViewCellModel(title: Constants.textFieldTableViewCellModelFirstNameTitle, userDataKey: \.firstName),
        TextFieldTableViewCellModel(title: Constants.textFieldTableViewCellModelLastNameTitle, userDataKey: \.lastName),
        TextFieldTableViewCellModel(title: Constants.textFieldTableViewCellModelEmailTitle, userDataKey: \.email),
        TextFieldTableViewCellModel(title: Constants.textFieldTableViewCellModelPasswordTitle, userDataKey: \.password)
    ]
    
    private let existingUserTextFieldTableViewCellModels = [
        TextFieldTableViewCellModel(title: Constants.textFieldTableViewCellModelEmailTitle, userDataKey: \.email),
        TextFieldTableViewCellModel(title: Constants.textFieldTableViewCellModelPasswordTitle, userDataKey: \.password)
    ]
    
    private var textFieldTableViewCellModels: [TextFieldTableViewCellModel] {
        switch userStatus {
        case .new: return newUserTextFieldTableViewCellModels
        case .existing: return existingUserTextFieldTableViewCellModels
        }
    }
    
    // MARK: - Dependencies
    var httpClient: HTTPClient
    var keyValueStore: KeyValueStore
    var userAuthManager: UserAuthManager
    
    // MARK: - View Settable Properties
    var userStatus: UserStatus = .new {
        didSet { update() }
    }
    
    var textFieldTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]() {
        didSet { updateTableViewSectionModels() }
    }
    
    var userDidSignInHandler: ((User.ID) -> Void) = { _ in }
    
    var errorHandler: ((Error) -> Void) = { _ in }
    
    // MARK: - Dynamic Properties
    private(set) lazy var tableViewSectionModels = Dynamic(makeTableViewSectionModels())
    
    private(set) lazy var completedButtonText = Dynamic(makeCompletedButtonText())
    
    enum CellIdentifier: String {
        case textFieldTableViewCell
    }
    
    private struct Constants {
        static let textFieldTableViewCellModelFirstNameTitle = "First Name"
        static let textFieldTableViewCellModelLastNameTitle = "Last Name"
        static let textFieldTableViewCellModelEmailTitle = "Email"
        static let textFieldTableViewCellModelPasswordTitle = "Password"
        
        static let textFieldTableViewCellViewModelHeight = Double(50)
        
        static let completedButtonNewUserStatusText = "Sign Up"
        static let completedButtonExistingUserStatusText = "Sign In"
    }
    
    init(httpClient: HTTPClient = URLSession.shared,
         keyValueStore: KeyValueStore = UserDefaults.standard,
         userAuthManager: UserAuthManager = Auth.auth()) {
        self.httpClient = httpClient
        self.keyValueStore = keyValueStore
        self.userAuthManager = userAuthManager
    }
    
    // MARK: - Setup Methods
    private func update() {
        updateTableViewSectionModels()
        updateCompletedButtonText()
    }
    
    private func updateTableViewSectionModels() {
        tableViewSectionModels.value = makeTableViewSectionModels()
    }
    
    private func updateCompletedButtonText() {
        completedButtonText.value = makeCompletedButtonText()
    }
    
    // MARK: - Download Methods
    func beginCompleteDownload() {
        do {
            try beginSignInUserDownload()
                .done { self.userDidSignInHandler($0.id) }
                .catch { self.errorHandler($0) }
        } catch { errorHandler(error) }
    }
    
    private func beginCreateAndSignInUserDownload() throws -> Promise<User> {
        guard let firstName = userData.firstName
            else { throw UserAuthViewModelError.needFirstName }
        guard let lastName = userData.lastName
            else { throw UserAuthViewModelError.needLastName }
        guard let email = userData.email
            else { throw UserAuthViewModelError.needEmail }
        guard let password = userData.password
            else { throw UserAuthViewModelError.needPassword }
        return userAuthManager.createAndSignInUser(email: email, password: password)
            .then { self.userAuthManager.getCurrentUserIDToken() }
            .then { self.createUser(data: .init(email: email, firstName: firstName, lastName: lastName), token: $0) }
    }
    
    private func beginSignInUserDownload() throws -> Promise<User> {
        guard let email = userData.email
            else { throw UserAuthViewModelError.needEmail }
        guard let password = userData.password
            else { throw UserAuthViewModelError.needPassword }
        return userAuthManager.signInUser(email: email, password: password)
            .then { self.userAuthManager.getCurrentUserIDToken() }
            .then { self.getTokenUser(token: $0) }
    }
    
    private func makeSignInUserDownload() throws -> Promise<User> {
        switch userStatus {
        case .new: return try beginCreateAndSignInUserDownload()
        case .existing: return try beginSignInUserDownload()
        }
    }
    
    private func createUser(data: CreateUserRequestData, token: JWT) -> Promise<User> {
        do {
            return try httpClient.send(apiURLRequestFactory.makeCreateUserRequest(data: data, token: token)).validate()
                .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode(User.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
    }
    
    private func getTokenUser(token: JWT) -> Promise<User> {
        return httpClient.send(apiURLRequestFactory.makeGetTokenUserRequest(token: token)).validate()
            .map { try self.apiURLRequestFactory.defaultJSONDecoder.decode(User.self, from: $0.data) }
    }
    
    // MARK: - Factory Methods
    func makeCompletedButtonText() -> String {
        switch userStatus {
        case .new: return Constants.completedButtonNewUserStatusText
        case .existing: return Constants.completedButtonExistingUserStatusText
        }
    }
    
    // MARK: - Section Model Methods
    private func makeTableViewSectionModels() -> [UITableViewSectionModel] {
        return [makeTextFieldTableViewSectionModel()]
    }
    
    private func makeTextFieldTableViewSectionModel() -> UITableViewSectionModel {
        return UITableViewSectionModel(cellViewModels: textFieldTableViewCellModels.map(makeTextFieldTableViewCellViewModel))
    }
    
    // MARK: - Cell View Model Methods
    private func makeTextFieldTableViewCellViewModel(cellModel: TextFieldTableViewCellModel) -> TextFieldTableViewCellViewModel {
        return TextFieldTableViewCellViewModel(
            identifier: CellIdentifier.textFieldTableViewCell.rawValue,
            height: .fixed(Constants.textFieldTableViewCellViewModelHeight),
            actions: textFieldTableViewCellViewModelActions,
            configurationData: .init(title: cellModel.title) { self.userData[keyPath: cellModel.userDataKey] = $0 }
        )
    }
}

extension UserAuthViewModel {
    enum UserStatus {
        case new, existing
    }
}

private extension UserAuthViewModel {
    struct UserData {
        var firstName: String?
        var lastName: String?
        var email: String?
        var password: String?
    }
}

private extension UserAuthViewModel {
    struct TextFieldTableViewCellModel {
        let title: String
        let userDataKey: WritableKeyPath<UserData, String?>
    }
}

extension UserAuthViewModel {
    struct TextFieldTableViewCellViewModel: UITableViewCellViewModel {
        let identifier: String
        let height: UITableViewCellViewModelHeight
        let actions: [UITableViewCellAction: UITableViewCellActionHandler]
        let configurationData: ConfigurationData
        
        struct ConfigurationData {
            let title: String
            let textFieldTextDidUpdateHandler: (String?) -> Void
        }
    }
}

enum UserAuthViewModelError: Error {
    case needFirstName
    case needLastName
    case needEmail
    case needPassword
}
