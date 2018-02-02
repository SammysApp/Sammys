//
//  HomeViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum HomeViewKey {
    case foods, faves
}

enum HomeItemKey {
    case food, fave
}

enum HomeCellIdentifier: String {
    case itemsCell
}

protocol HomeItem {
    var key: HomeItemKey { get }
    var cellIdentifier: HomeCellIdentifier { get }
    var title: String { get }
}

class HomeViewModel {
    var viewKey: HomeViewKey = .foods
    private var items = [HomeItem]()
    var user: User? {
        return UserDataStore.shared.user
    }
    
    var id = UUID().uuidString
    lazy var favoritesValueDidChange: (([Salad]) -> Void)? = { favorites in
        
    }
    
    init() {
        getItems()
    }
    
    func getItems(completed: (() -> Void)? = nil) {
        switch viewKey {
        case .foods:
            items = [FoodHomeItem(title: "Salad")]
        case .faves:
            let didGetFavorites: ([Salad]) -> Void = { favorites in
                var items = [HomeItem]()
                for food in favorites {
                    items.append(FaveHomeItem(food: food))
                }
                self.items = items
                completed?()
            }
            if user?.favorites != nil {
                didGetFavorites(user!.favorites!)
            } else {
                UserAPIClient.fetchFavorites(for: user!) { favorites in
                    didGetFavorites(favorites)
                }
            }
        }
    }
    
    func numberOfItems(in section: Int) -> Int {
        return items.count
    }
    
    func item(for indexPath: IndexPath) -> HomeItem {
        return items[indexPath.row]
    }
}

extension HomeViewModel: UserAPIObserver {
    var userStateDidChange: ((UserState) -> Void)? {
        return nil
    }
}

struct FoodHomeItem: HomeItem {
    let key: HomeItemKey = .food
    let cellIdentifier: HomeCellIdentifier = .itemsCell
    let title: String
}

struct FaveHomeItem: HomeItem {
    let key: HomeItemKey = .fave
    let cellIdentifier: HomeCellIdentifier = .itemsCell
    var title: String {
        return food.title
    }
    let food: Food
}
