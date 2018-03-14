//
//  UserViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/30/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import Stripe

/// A type that represents the type of user cell item.
enum UserItemKey {
    case name, email, creditCard, paymentMethods, logOut
}

/// A user cell item.
protocol UserItem {
    var key: UserItemKey { get }
    var cellIdentifier: String { get }
    var title: String { get }
}

enum UserItemCellIdentifier: String {
    case cell, buttonCell
}

protocol UserViewModelDelegate {
    /// Called by delegate if user changed.
    var userDidChange: () -> Void { get }
}

/// A section in the user view.
struct UserSection {
    /// The tile of the section.
    let title: String?
    
    /// The items in the section.
    let items: [UserItem]
    
    init(title: String? = nil, items: [UserItem]) {
        self.title = title
        self.items = items
    }
}

class UserViewModel {
    var delegate: UserViewModelDelegate?
    let id = UUID().uuidString
    
    private var user: User? {
        return UserDataStore.shared.user
    }
    
    /// The sections to populate the user view with.
    var sections: [UserSection] {
        var items = [UserSection]()
        guard let user = user else { return items }
        items.append(UserSection(items: [
            NameUserItem(name: user.name),
            EmailUserItem(email: user.email)
        ]))
        items.append(UserSection(items: [
            CreditCardUserItem(),
            PaymentMethodsUserItem(),
            LogOutUserItem()
        ]))
        return items
    }
    
    var needsUser: Bool {
        return user == nil
    }
    
    var numberOfSections: Int {
        return sections.count
    }
    
    // A Stripe customer context created with a fetched ephemeral key.
    var stripeCustomerContext: STPCustomerContext {
        return STPCustomerContext(keyProvider: EphemeralKeyProvider.shared)
    }
    
    init() {
        UserAPIClient.addObserver(self)
    }
    
    func numberOfRows(in section: Int) -> Int {
        return sections[section].items.count
    }
    
    func item(for indexPath: IndexPath) -> UserItem? {
        let userItems = sections[indexPath.section].items
        return userItems[indexPath.row]
    }
    
    func setUserAsCustomer(with tokenID: String) {
        guard let user = self.user else { return }
        PayAPIClient.createNewCustomer(with: tokenID, email: user.email) { result in
            switch result {
            case .success(let customer):
                UserAPIClient.set(customer.id, for: user)
            case .failure(let message): print(message)
            }
        }
    }
}

extension UserViewModel: UserAPIObserver {
    var userStateDidChange: ((UserState) -> Void)? { return { _ in
        self.delegate?.userDidChange()
    }}
}

struct NameUserItem: UserItem {
    let key: UserItemKey = .name
    let cellIdentifier = UserItemCellIdentifier.cell.rawValue
    let title = "Name"
    let name: String
}

struct EmailUserItem: UserItem {
    let key: UserItemKey = .email
    let cellIdentifier = UserItemCellIdentifier.cell.rawValue
    let title = "Email"
    let email: String
}

struct CreditCardUserItem: UserItem {
    let key: UserItemKey = .creditCard
    let cellIdentifier = UserItemCellIdentifier.buttonCell.rawValue
    let title = "Add Credit Card"
}

struct PaymentMethodsUserItem: UserItem {
    let key: UserItemKey = .paymentMethods
    let cellIdentifier = UserItemCellIdentifier.buttonCell.rawValue
    let title = "Payment Methods"
}

struct LogOutUserItem: UserItem {
    let key: UserItemKey = .logOut
    let cellIdentifier = UserItemCellIdentifier.buttonCell.rawValue
    let title = "Log Out"
    let didSelect: () -> Void = {
        UserAPIClient.signOut()
    }
}
