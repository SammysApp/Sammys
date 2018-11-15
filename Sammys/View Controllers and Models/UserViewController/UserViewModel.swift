//
//  UserViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/30/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

enum UserCellIdentifier: String {
	case detailCell
}

protocol UserViewModelViewDelegate {
	func cellHeight() -> Double
}

class UserViewModel {
	typealias Section = AnyViewModelTableViewSection
	
	private let viewDelegate: UserViewModelViewDelegate
	private let userAPIManager = UserAPIManager()
	
	private var userStateObservable: Variable<Promise<UserState>> {
		didSet { beginObservingUserState() }
	}
	private(set) var userState = Dynamic(UserState.noUser)
	private var user: User?
	
	private var sections: [Section] {
		guard let user = user else { return [] }
		return [myInfoSection(for: user)]
	}
	
	func myInfoSection(for user: User) -> Section {
		return Section(
			title: Constants.myInfoSectionTitle,
			cellViewModels: [
				DetailTableViewCellViewModelFactory(identifier: UserCellIdentifier.detailCell.rawValue, height: viewDelegate.cellHeight(), titleText: Constants.nameCellTitle, detailText: user.name).create(),
				DetailTableViewCellViewModelFactory(identifier: UserCellIdentifier.detailCell.rawValue, height: viewDelegate.cellHeight(), titleText: Constants.emailCellTitle, detailText: user.email).create()
			]
		)
	}
    
    var numberOfSections: Int {
        return sections.count
    }
	
	private struct Constants {
		static let myInfoSectionTitle = "My Info"
		static let nameCellTitle = "Name"
		static let emailCellTitle = "Email"
	}
	
	init(_ viewDelegate: UserViewModelViewDelegate) {
		self.viewDelegate = viewDelegate
		self.userStateObservable = userAPIManager.observableUserState()
	}
	
	private func beginObservingUserState() {
		userStateObservable.add(UpdateClosure<Promise<UserState>>(id: UUID().uuidString)
		{ $0.get(self.setup).catch { print($0) } })
	}
	
	private func setup(_ userState: UserState) {
		self.userState.value = userState
		if case .currentUser(let user) = userState { self.user = user }
	}
    
    func numberOfRows(inSection section: Int) -> Int {
        return sections[section].cellViewModels.count
    }
    
    func cellViewModel(for indexPath: IndexPath) -> Section.CellViewModel {
        return sections[indexPath.section].cellViewModels[indexPath.row]
    }
    
    func sectionTitle(for section: Int) -> String? {
        return sections[section].title
    }
}
