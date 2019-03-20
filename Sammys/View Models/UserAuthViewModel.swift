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
    private let textFieldTableViewCellModels = [
        TextFieldTableViewCellModel(title: "First Name", userDataKey: \.firstName),
        TextFieldTableViewCellModel(title: "Last Name", userDataKey: \.lastName),
        TextFieldTableViewCellModel(title: "Email", userDataKey: \.email),
        TextFieldTableViewCellModel(title: "Password", userDataKey: \.password)
    ]
    
    private let apiURLRequestFactory = APIURLRequestFactory()
    
    // MARK: - Dependencies
    var httpClient: HTTPClient
    var userAuthManager: UserAuthManager
    
    // MARK: - View Settable Properties
    var textFieldTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]()
    var errorHandler: ((Error) -> Void)?
    
    // MARK: - View Gettable Properties
    var completedButtonText: String { return "Sign Up" }
    
    private struct Constants {
        static let textFieldTableViewCellViewModelHeight: Double = 50
    }
    
    init(httpClient: HTTPClient = URLSession.shared,
         userAuthManager: UserAuthManager = Auth.auth()) {
        self.httpClient = httpClient
        self.userAuthManager = userAuthManager
    }
    
    // MARK: - Download Methods
    func beginCompleteDownload() {
        beginCreateUserDownload()
    }
    
    private func beginCreateUserDownload() {
        guard let firstName = userData.firstName else { return }
        guard let lastName = userData.lastName else { return }
        guard let email = userData.email else { return }
        guard let password = userData.password else { return }
        userAuthManager.createAndSignInUser(email: email, password: password)
            .then { self.userAuthManager.getCurrentUserIDJWT() }
            .then { self.createUser(data: .init(email: email, firstName: firstName, lastName: lastName), jwt: $0) }
            .done { _ in }.catch { self.errorHandler?($0) }
    }
    
    private func createUser(data: CreateUserData, jwt: JWT) -> Promise<User> {
        do {
            return try httpClient.send(apiURLRequestFactory.makeCreateUserRequest(data: data, jwt: jwt)).validate()
                .map { try JSONDecoder().decode(User.self, from: $0.data) }
        } catch { preconditionFailure(error.localizedDescription) }
    }
    
    // MARK: - Section Model Methods
    func makeTableViewSectionModels() -> [UITableViewSectionModel] {
        return [makeTextFieldTableViewSectionModel()]
    }
    
    private func makeTextFieldTableViewSectionModel() -> UITableViewSectionModel {
        return UITableViewSectionModel(cellViewModels: textFieldTableViewCellModels.map(makeTextFieldTableViewCellViewModel))
    }
    
    // MARK: - Cell View Model Methods
    private func makeTextFieldTableViewCellViewModel(model: TextFieldTableViewCellModel) -> TextFieldTableViewCellViewModel {
        return TextFieldTableViewCellViewModel(
            identifier: UserAuthViewController.CellIdentifier.textFieldTableViewCell.rawValue,
            height: .fixed(Constants.textFieldTableViewCellViewModelHeight),
            actions: textFieldTableViewCellViewModelActions,
            configurationData: .init(title: model.title) { self.userData[keyPath: model.userDataKey] = $0; print(self.userData) }
        )
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
