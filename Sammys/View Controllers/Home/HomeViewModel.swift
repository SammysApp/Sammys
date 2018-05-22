//
//  HomeViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

/// A type that represents the state of the home view.
enum HomeViewKey {
    case foods, faves
}

protocol HomeViewModelDelegate {
    var collectionViewDataDidChange: () -> Void { get }
    var didSelectFood: () -> Void { get }
    var didSelectFavorite: (Food) -> Void { get }
}

/// A home section in the home view.
struct HomeSection {
    /// The tile of the section.
    let title: String?
    
    /// The cell view models in the section.
    let cellViewModels: [CollectionViewCellViewModel]
    
    init(title: String? = nil, cellViewModels: [CollectionViewCellViewModel]) {
        self.title = title
        self.cellViewModels = cellViewModels
    }
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
    
    let contextBounds: CGRect
    
    var numberOfSections: Int {
        return sections.count
    }
    
    var isNoItems: Bool {
        return sections.isEmpty
    }
    
    var bagQuantityLabelText: String {
        let quantity = BagDataStore.shared.quantity
        // Save quantity last used to check later for update.
        currentBagQuantity = quantity
        return quantity > 0 ? "\(quantity)" : ""
    }
    
    var currentBagQuantity = 0
    
    var needsBagQuantityUpdate: Bool {
        return currentBagQuantity != BagDataStore.shared.quantity
    }
    
    init(contextBounds: CGRect, _ delegate: HomeViewModelDelegate? = nil) {
        self.contextBounds = contextBounds
        self.delegate = delegate
        UserAPIClient.addObserver(self)
        setSectionsWithFood()
    }
    
    private func setSectionsWithFood() {
        sections = [
            HomeSection(cellViewModels: [
                FoodHomeCollectionViewCellViewModelFactory(
                    size: cellSize(for: .foods),
                    titleText: FoodType.salad.title,
                    selectionCommand: FoodHomeCollectionViewCellSelectionCommand(didSelect: { self.delegate?.didSelectFood() })).create()
            ])
        ]
    }
    
    private func setSections(for favorites: [FavoriteGroup]) {
        var sections = [HomeSection]()
        for favoriteGroup in favorites {
            sections.append(HomeSection(
                title: favoriteGroup.foodType.title,
                cellViewModels: favoriteGroup.favorites.map { food in FoodHomeCollectionViewCellViewModelFactory(
                    size: cellSize(for: .faves),
                    titleText: food.title,
                    selectionCommand: FoodHomeCollectionViewCellSelectionCommand(didSelect: { self.delegate?.didSelectFavorite(food) })).create() }))
        }
        self.sections = sections
    }
    
    private func setupFaves() {
        // Only allow to display faves if there's a signed in user.
        guard let user = user else { return }
        if !user.favorites.isEmpty {
            setSections(for: user.favorites)
            delegate?.collectionViewDataDidChange()
        } else {
            UserAPIClient.fetchFavorites(for: user) { result in
                switch result {
                case .success(let favorites):
                    self.setSections(for: favorites)
                case .failure:
                    self.sections = []
                }
                self.delegate?.collectionViewDataDidChange()
            }
        }
    }
    
    func numberOfItems(in section: Int) -> Int {
        return sections[section].cellViewModels.count
    }
    
    func cellViewModel(for indexPath: IndexPath) -> CollectionViewCellViewModel {
        return sections[indexPath.section].cellViewModels[indexPath.row]
    }
    
    func title(for section: Int) -> String? {
        return sections[section].title
    }
    
    private func cellSize(for viewKey: HomeViewKey) -> CGSize {
        switch viewKey {
        case .foods: return CGSize(width: contextBounds.width - 20, height: 200)
        case .faves:
            let size = (contextBounds.width / 2) - 15
            return CGSize(width: size, height: size)
        }
    }
    
    func setupView(for viewKey: HomeViewKey) {
        self.viewKey = viewKey
        switch viewKey {
        case .foods:
            setSectionsWithFood()
            delegate?.collectionViewDataDidChange()
        case .faves: setupFaves()
        }
    }
    
    func toggleFavesView() {
        if viewKey == .faves {
            setupView(for: .foods)
        } else {
            setupView(for: .faves)
        }
    }
    
    func setFavorite(_ food: Food) {
        guard let user = user else { return }
        UserAPIClient.set(food as! Salad, for: user)
    }
}

extension HomeViewModel: UserAPIObserver {
    var favoritesValueDidChange: (([FavoriteGroup]) -> Void)? {
        return { favorites in
            if self.viewKey == .faves {
                self.setSections(for: favorites)
                self.delegate?.collectionViewDataDidChange()
            }
        }
    }
}
