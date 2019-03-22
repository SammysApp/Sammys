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
    var userAuthManager: UserAuthManager
    
    private var userID: User.ID?
    
    // MARK: - Section Model Properties
    private var userDetailsTableViewSectionModel: UITableViewSectionModel? {
        didSet { tableViewSectionModels.value = makeTableViewSectionModels() }
    }
    
    // MARK: - View Settable Properties
    var needsUserAuthHandler: (() -> Void)?
    var userDetailTableViewCellViewModelActions = [UITableViewCellAction : UITableViewCellActionHandler]()
    var errorHandler: ((Error) -> Void)?
    
    // MARK: - Dynamic Properties
    let tableViewSectionModels = Dynamic([UITableViewSectionModel]())
    let isUserDownloading = Dynamic(false)
    
    enum CellIdentifier: String {
        case tableViewCell
    }
    
    private struct Constants {
        static let userDetailTableViewCellViewModelHeight: Double = 60
    }
    
    init(httpClient: HTTPClient = URLSession.shared,
         userAuthManager: UserAuthManager = Auth.auth()) {
        self.httpClient = httpClient
        self.userAuthManager = userAuthManager
    }
    
    // MARK: - Download Methods
    func beginDownloads() {
        beginUserDownload()
    }
    
    private func beginUserDownload() {
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
                self.userDetailsTableViewSectionModel = self.makeUserDetailsTableViewSectionModel(userDetails: self.makeUserDetails(user: user))
            }.catch { error in
                switch error {
                case UserAuthManagerError.noCurrentUser: self.needsUserAuthHandler?()
                default: self.errorHandler?(error)
                }
            }
    }
    
    private func getUser(token: JWT) -> Promise<User> {
        return httpClient.send(apiURLRequestFactory.makeGetUserRequest(id: userID ?? preconditionFailure(), token: token))
            .map { try JSONDecoder().decode(User.self, from: $0.data) }
    }
    
    private func getTokenUser(token: JWT) -> Promise<User> {
        return httpClient.send(apiURLRequestFactory.makeGetTokenUserRequest(token: token))
            .map { try JSONDecoder().decode(User.self, from: $0.data) }
    }
    
    // MARK: - Factory Methods
    private func makeUserDetails(user: User) -> [UserDetail] {
        return [
            UserDetail(title: "Name", text: user.firstName + " " + user.lastName),
            UserDetail(title: "Email", text: user.email)
        ]
    }
    
    // MARK: - Section Model Methods
    private func makeTableViewSectionModels() -> [UITableViewSectionModel] {
        var sectionModels = [UITableViewSectionModel]()
        if let userDetailsModel = userDetailsTableViewSectionModel { sectionModels.append(userDetailsModel) }
        return sectionModels
    }
    
    private func makeUserDetailsTableViewSectionModel(userDetails: [UserDetail]) -> UITableViewSectionModel {
        return UITableViewSectionModel(cellViewModels: userDetails.map(makeUserDetailTableViewCellViewModel))
    }
    
    // MARK: - Cell View Model Methods
    private func makeUserDetailTableViewCellViewModel(userDetail: UserDetail) -> UserDetailTableViewCellViewModel {
        return UserDetailTableViewCellViewModel(
            identifier: CellIdentifier.tableViewCell.rawValue,
            height: .fixed(Constants.userDetailTableViewCellViewModelHeight),
            actions: userDetailTableViewCellViewModelActions,
            configurationData: .init(text: userDetail.text)
        )
    }
}

private extension UserViewModel {
    struct UserDetail {
        let title: String
        let text: String
    }
}

extension UserViewModel {
    struct UserDetailTableViewCellViewModel: UITableViewCellViewModel {
        let identifier: String
        let height: UITableViewCellViewModelHeight
        let actions: [UITableViewCellAction : UITableViewCellActionHandler]
        let configurationData: ConfigurationData
        
        struct ConfigurationData {
            let text: String
        }
    }
}
