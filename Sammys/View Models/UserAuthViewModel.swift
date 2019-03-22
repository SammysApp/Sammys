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
    private var userData = UserData()
    
    private let newUserTextFieldTableViewCellModels = [
        TextFieldTableViewCellModel(title: "First Name", userDataKey: \.firstName),
        TextFieldTableViewCellModel(title: "Last Name", userDataKey: \.lastName),
        TextFieldTableViewCellModel(title: "Email", userDataKey: \.email),
        TextFieldTableViewCellModel(title: "Password", userDataKey: \.password)
    ]
    private let existingUserTextFieldTableViewCellModels = [
        TextFieldTableViewCellModel(title: "Email", userDataKey: \.email),
        TextFieldTableViewCellModel(title: "Password", userDataKey: \.password)
    ]
    private var textFieldTableViewCellModels: [TextFieldTableViewCellModel] {
        switch userStatus {
        case .new: return newUserTextFieldTableViewCellModels
        case .existing: return existingUserTextFieldTableViewCellModels
        }
    }
    
    private let apiURLRequestFactory = APIURLRequestFactory()
    
    // MARK: - Dependencies
    var httpClient: HTTPClient
    var keyValueStore: KeyValueStore
    var userAuthManager: UserAuthManager
    
    // MARK: - View Settable Properties
    var userStatus: UserStatus = .new
    var textFieldTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]()
    var userDidSignInHandler: ((User.ID) -> Void)?
    var errorHandler: ((Error) -> Void)?
    
    // MARK: - View Gettable Properties
    var tableViewSectionModels: [UITableViewSectionModel] {
        return makeTableViewSectionModels()
    }
    var completedButtonText: String {
        switch userStatus {
        case .new: return "Sign Up"
        case .existing: return "Sign In"
        }
    }
    
    enum CellIdentifier: String {
        case textFieldTableViewCell
    }
    
    private struct Constants {
        static let textFieldTableViewCellViewModelHeight: Double = 50
    }
    
    init(httpClient: HTTPClient = URLSession.shared,
         keyValueStore: KeyValueStore = UserDefaults.standard,
         userAuthManager: UserAuthManager = Auth.auth()) {
        self.httpClient = httpClient
        self.keyValueStore = keyValueStore
        self.userAuthManager = userAuthManager
    }
    
    // MARK: - Download Methods
    func beginCompleteDownload() {
        switch userStatus {
        case .new: beginCreateUserDownload()
        case .existing: beginSignInUserDownload()
        }
    }
    
    private func beginCreateUserDownload() {
        guard let firstName = userData.firstName else { return }
        guard let lastName = userData.lastName else { return }
        guard let email = userData.email else { return }
        guard let password = userData.password else { return }
        userAuthManager.createAndSignInUser(email: email, password: password)
            .then { self.userAuthManager.getCurrentUserIDToken() }
            .then { self.createUser(data: .init(email: email, firstName: firstName, lastName: lastName), token: $0) }
            .done { self.userDidSignInHandler?($0.id) }
            .catch { self.errorHandler?($0) }
    }
    
    private func beginSignInUserDownload() {
        guard let email = userData.email else { return }
        guard let password = userData.password else { return }
        userAuthManager.signInUser(email: email, password: password)
            .then { self.userAuthManager.getCurrentUserIDToken() }
            .then { self.getTokenUser(token: $0) }
            .done { self.userDidSignInHandler?($0.id) }
            .catch { self.errorHandler?($0) }
    }
    
    private func createUser(data: CreateUserData, token: JWT) -> Promise<User> {
        do {
            return try httpClient.send(apiURLRequestFactory.makeCreateUserRequest(data: data, token: token)).validate()
                .map { try JSONDecoder().decode(User.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
    }
    
    private func getTokenUser(token: JWT) -> Promise<User> {
        return httpClient.send(apiURLRequestFactory.makeGetTokenUserRequest(token: token))
            .map { try JSONDecoder().decode(User.self, from: $0.data) }
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
        let actions: [UITableViewCellAction : UITableViewCellActionHandler]
        let configurationData: ConfigurationData
        
        struct ConfigurationData {
            let title: String
            let textFieldTextUpdateHandler: (String?) -> Void
        }
    }
}
