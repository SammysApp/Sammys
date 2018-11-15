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
	var userState: UserState
}

enum UserCellIdentifier: String {
	case detailCell
}

protocol UserViewModelViewDelegate {
	func cellHeight() -> Double
}

class UserViewModel {
	typealias Section = AnyViewModelTableViewSection
	
	private let parcel: UserViewModelParcel
	private let viewDelegate: UserViewModelViewDelegate
	
	var userState: UserState { return parcel.userState }
	private var user: User? {
		guard case .currentUser(let user) = userState else { return nil }
		return user
	}
	
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
	
	init(parcel: UserViewModelParcel, viewDelegate: UserViewModelViewDelegate) {
		self.parcel = parcel
		self.viewDelegate = viewDelegate
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
