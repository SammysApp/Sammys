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

protocol HomeViewModelDelegate {
    var favoritesDidChange: () -> Void { get }
}

/// A home cell item.
protocol HomeItem {
    var key: HomeItemKey { get }
    var cellIdentifier: HomeCellIdentifier { get }
    var title: String { get }
}

/// A home section in the home view.
struct HomeSection {
    /// The tile of the section.
    let title: String?
    
    /// The items in the section.
    let items: [HomeItem]
}

class HomeViewModel {
    var delegate: HomeViewModelDelegate?
    
    /// The current view state key.
    var viewKey: HomeViewKey = .foods
    
    /// The sections to populate home with based on the view state.
    private var sections = [HomeSection]()
    
    var user: User? {
        return UserDataStore.shared.user
    }
    
    let id = UUID().uuidString
    
    var numberOfSections: Int {
        return sections.count
    }
    
    init(_ delegate: HomeViewModelDelegate? = nil) {
        getItems()
        UserAPIClient.addObserver(self)
    }
    
    /// Gets the items for the current view state and calls `completed` closure upon finishing.
    func getItems(completed: (() -> Void)? = nil) {
        getItems(for: viewKey, completed: completed)
    }
    
    /// Gets the appropriate items for the given view key. Calls `completed` closure upon finishing.
    private func getItems(for viewKey: HomeViewKey, completed: (() -> Void)? = nil) {
        switch viewKey {
        case .foods:
            let section = HomeSection(title: nil, items: [FoodHomeItem(title: FoodType.salad.title)])
            sections = [section]
            completed?()
        case .faves:
            // Only allow to display faves if there's a signed in user.
            guard let user = user else { return }
            if !user.favorites.isEmpty {
                setSections(for: user.favorites)
                completed?()
            } else {
                UserAPIClient.fetchFavorites(for: user) { (result, favorites)  in
                    self.setSections(for: favorites)
                    completed?()
                }
            }
        }
    }
    
    private func setSections(for favorites: [FavoriteGroup]) {
        var sections = [HomeSection]()
        for favoriteGroup in favorites {
            var items = [HomeItem]()
            for food in favoriteGroup.favorites {
                items.append(FaveHomeItem(food: food))
            }
            sections.append(HomeSection(title: favoriteGroup.foodType.title, items: items))
        }
        self.sections = sections
    }
    
    func numberOfItems(in section: Int) -> Int {
        return sections[section].items.count
    }
    
    func item(for indexPath: IndexPath) -> HomeItem {
        return sections[indexPath.section].items[indexPath.row]
    }
    
    func title(for section: Int) -> String? {
        return sections[section].title
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
    var favoritesValueDidChange: (([FavoriteGroup]) -> Void)? {
        return { favorites in
            if self.viewKey == .faves {
                self.setSections(for: favorites)
                self.delegate?.favoritesDidChange()
            }
        }
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
