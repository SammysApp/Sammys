//
//  HomeViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

/// A type that represents the state of the home view.
enum HomeViewKey {
    case foods, faves
}

/// A type the represents the type of home cell item.
enum HomeItemKey {
    case food, fave
}

enum HomeCellIdentifier: String {
    case itemsCell
}

/// A type that represents a home cell item.
protocol HomeItem {
    var key: HomeItemKey { get }
    var cellIdentifier: HomeCellIdentifier { get }
    var title: String { get }
}

class HomeViewModel {
    /// The current view state key.
    var viewKey: HomeViewKey = .foods
    
    /// The items to populate home with based on the view state.
    private var items = [HomeItem]()
    
    /// The current user signed in.
    var user: User? {
        return UserDataStore.shared.user
    }
    
    let id = UUID().uuidString
    
    init() {
        getItems(for: viewKey)
    }
    
    /**
     Gets the appropriate items for the given view key. Calls `completed` closure upon finishing.
    */
    func getItems(for viewKey: HomeViewKey, completed: (() -> Void)? = nil) {
        switch viewKey {
        case .foods:
            items = [FoodHomeItem(title: FoodType.salad.rawValue)]
            completed?()
        case .faves:
            // Only allow to display faves if there's a signed in user.
            guard let user = user else { return }
            /// Gets called after user favorites fetched.
            let didGetFavorites: ([Salad]) -> Void = { favorites in
                var items = [HomeItem]()
                for food in favorites {
                    items.append(FaveHomeItem(food: food))
                }
                self.items = items
                completed?()
            }
            if !user.favorites.isEmpty {
                didGetFavorites(user.favorites)
            } else {
                UserAPIClient.fetchFavorites(for: user) { (result, favorites)  in
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
    
    func toggleFaves() {
        if viewKey != .faves {
            viewKey = .faves
        } else {
            viewKey = .foods
        }
    }
    
    func setFavorite(_ food: Food) {
        UserAPIClient.set(food as! Salad, for: user!)
    }
}

extension HomeViewModel: UserAPIObserver {
    var favoritesValueDidChange: (([Salad]) -> Void)? {
        return { favorites in
        
        }
    }
    
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
