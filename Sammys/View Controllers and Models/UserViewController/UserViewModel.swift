//
//  UserViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/30/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

struct UserViewModelParcel {
	let userState: UserState
}

protocol UserViewModelViewDelegate {
	func cellHeight() -> Double
}

enum UserCellIdentifier: String { case detailCell, buttonCell }

class UserViewModel {
	typealias Section = AnyViewModelTableViewSection
	
	var parcel: UserViewModelParcel?
	private let viewDelegate: UserViewModelViewDelegate
	
	private let userAPIManager = UserAPIManager()
	
	lazy var userState = { parcel?.userState }()
	var user: User? {
		guard let userState = userState,
			case .currentUser(let user) = userState
			else { return nil }
		return user
	}
	
	// MARK: - Data
	private var sections: [Section] {
		guard let user = user else { return [] }
		return [myInfoSection(for: user), buttonsSection()]
	}
	
	func myInfoSection(for user: User) -> Section {
		return Section(cellViewModels: [
			DetailTableViewCellViewModelFactory(
				identifier: UserCellIdentifier.detailCell.rawValue,
				height: viewDelegate.cellHeight(),
				titleText: Constants.nameCellTitle,
				detailText: user.name).create(),
			DetailTableViewCellViewModelFactory(
				identifier: UserCellIdentifier.detailCell.rawValue,
				height: viewDelegate.cellHeight(),
				titleText: Constants.emailCellTitle,
				detailText: user.email).create()
		])
	}
	
	func buttonsSection() -> Section {
		return Section(cellViewModels: [
			ButtonTableViewCellViewModelFactory(
				identifier: UserCellIdentifier.buttonCell.rawValue,
				height: viewDelegate.cellHeight(),
				buttonText: Constants.ordersCellTitle,
				selectionCommand: OrdersButtonTableViewCellSelectionCommand()).create(),
			ButtonTableViewCellViewModelFactory(
				identifier: UserCellIdentifier.buttonCell.rawValue,
				height: viewDelegate.cellHeight(),
				buttonText: Constants.logOutCellTitle,
				selectionCommand: LoginButtonTableViewCellSelectionCommand()).create()
		])
	}
    
    var numberOfSections: Int {
        return sections.count
    }
	
	private struct Constants {
		static let nameCellTitle = "Name"
		static let emailCellTitle = "Email"
		static let ordersCellTitle = "Your Orders"
		static let logOutCellTitle = "Log Out"
	}
	
	init(parcel: UserViewModelParcel?, viewDelegate: UserViewModelViewDelegate) {
		self.parcel = parcel
		self.viewDelegate = viewDelegate
	}
	
	func setupUserState() -> Promise<UserState> {
		return userAPIManager.currentUserState().get { self.userState = $0 }
	}
    
    func numberOfRows(inSection section: Int) -> Int {
        return sections[section].cellViewModels.count
    }
    
    func cellViewModel(for indexPath: IndexPath) -> Section.CellViewModel? {
		return sections[safe: indexPath.section]?.cellViewModels[safe: indexPath.row]
    }
    
    func sectionTitle(for section: Int) -> String? {
        return sections[section].title
    }
	
	func logOut() throws {
		do { try userAPIManager.signOut(); userState = .noUser }
		catch { throw error }
	}
}
