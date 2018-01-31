//
//  UserViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/30/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum UserItemKey {
    case name, email, creditCard, logOut
}

protocol UserItem {
    var key: UserItemKey { get }
    var cellIdentifier: String { get }
    var title: String { get }
}

class UserViewModel {
    private var user: User? {
        return UserDataStore.shared.user
    }
    
    var items: [Int : [UserItem]] {
        var items = [Int : [UserItem]]()
        guard let user = user else { return items }
        items[0] = [NameUserItem(name: user.name), EmailUserItem(email: user.email)]
        items[1] = [CreditCardUserItem(), LogOutUserItem()]
        return items
    }
    
    var needsUser: Bool {
        return user == nil
    }
    
    var numberOfSections: Int {
        return items.count
    }
    
    func numberOfRows(in section: Int) -> Int {
        return items[section]?.count ?? 0
    }
    
    func item(for indexPath: IndexPath) -> UserItem? {
        if let userItems = items[indexPath.section] {
            return userItems[indexPath.row]
        }
        return nil
    }
}

struct NameUserItem: UserItem {
    let key: UserItemKey = .name
    let cellIdentifier = "cell"
    let title = "Name"
    let name: String
}

struct EmailUserItem: UserItem {
    let key: UserItemKey = .email
    let cellIdentifier = "cell"
    let title = "Email"
    let email: String
}

struct CreditCardUserItem: UserItem {
    let key: UserItemKey = .creditCard
    let cellIdentifier = "buttonCell"
    let title = "Add Credit Card"
}

struct LogOutUserItem: UserItem {
    let key: UserItemKey = .logOut
    let cellIdentifier = "buttonCell"
    let title = "Log Out"
    let didSelect: () -> Void = {
        UserAPIClient.signOut()
    }
}
