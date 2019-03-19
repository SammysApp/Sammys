//
//  UserAuthViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/19/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

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
    
    // MARK: - View Settable Properties
    var textFieldTableViewCellViewModelActions = [UITableViewCellAction: UITableViewCellActionHandler]()
    var errorHandler: ((Error) -> Void)?
    
    private struct Constants {
        static let textFieldTableViewCellViewModelHeight: Double = 50
    }
    
    init(httpClient: HTTPClient = URLSession.shared) {
        self.httpClient = httpClient
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
