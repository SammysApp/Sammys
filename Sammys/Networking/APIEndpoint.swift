//
//  APIEndpoint.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/13/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

enum APIEndpoint: HTTPEndpoint {
    // MARK: - GET
    /// GET `/users/tokenUser`
    case getTokenUser
    /// GET `/users/:user`
    case getUser(User.ID)
    /// GET `/users/:user/outstandingOrders`
    case getUserOutstandingOrders(User.ID)
    /// GET `/users/:user/cards`
    case getUserCards(User.ID)
    /// GET `/storeHours`
    case getStoreHours
    /// GET `/categories`
    case getCategories
    /// GET `/categories/:category`
    case getCategory(Category.ID)
    /// GET `/categories/:category/subcategories`
    case getSubcategories(Category.ID)
    /// GET `/categories/:category/item`
    case getCategoryItems(Category.ID)
    /// GET `/categories/:category/item/:item/modifiers`
    case getItemModifiers(Category.ID, Item.ID)
    /// GET `/constructedItems/:constructedItem/items`
    case getConstructedItemItems(ConstructedItem.ID)
    /// GET `/outstandingOrders/:outstandingOrder`
    case getOutstandingOrder(OutstandingOrder.ID)
    /// GET `/outstandingOrders/:outstandingOrder/constructedItems`
    case getOutstandingOrderConstructedItems(OutstandingOrder.ID)
    
    // MARK: - POST
    /// POST `/users`
    case createUser
    /// POST `/users/:user/cards`
    case createUserCard(User.ID)
    /// POST `/users/:user/purchasedOrders`
    case createUserPurchasedOrder(User.ID)
    /// POST `/constructedItems`
    case createConstructedItem
    /// POST `/constructedItems/:constructedItem/items`
    case addConstructedItemItems(ConstructedItem.ID)
    /// POST `/outstandingOrders`
    case createOutstandingOrder
    /// POST `/outstandingOrders/:outstandingOrder/constructedItems`
    case addOutstandingOrderConstructedItems(OutstandingOrder.ID)
    
    // MARK: - PUT
    /// PUT `/constructedItems/:constructedItem`
    case updateConstructedItem(ConstructedItem.ID)
    /// PUT `/outstandingOrders/:outstandingOrder`
    case updateOutstandingOrder(OutstandingOrder.ID)
    
    // MARK: - PATCH
    /// PATCH `/constructedItems/:constructedItem`
    case partiallyUpdateConstructedItem(ConstructedItem.ID)
    /// PATCH `/outstandingOrders/:outstandingOrder/constructedItems/:constructedItem`
    case partiallyUpdateOutstandingOrderConstructedItem(OutstandingOrder.ID, ConstructedItem.ID)
    
    // MARK: - DELETE
    /// DELETE `/constructedItems/:constructedItem/items/:categoryItem`
    case removeConstructedItemItem(ConstructedItem.ID, Item.CategoryItemID)
    /// DELETE `/outstandingOrders/:outstandingOrder/constructedItems/:constructedItem`
    case removeOutstandingOrderConstructedItem(OutstandingOrder.ID, ConstructedItem.ID)
    
    private enum Version: String { case v1 }
    private var version: Version { return .v1 }
    
    var endpoint: (HTTPMethod, URLPath) {
        switch self {
        case .getTokenUser:
            return (.GET, "/\(version)/users/tokenUser")
        case .getUser(let id):
            return (.GET, "/\(version)/users/\(id)")
        case .getUserOutstandingOrders(let id):
            return (.GET, "/\(version)/users/\(id)/outstandingOrders")
        case .getUserCards(let id):
            return (.GET, "/\(version)/users/\(id)/cards")
        case .getStoreHours:
            return (.GET, "/\(version)/storeHours")
        case .getCategories:
            return (.GET, "/\(version)/categories")
        case .getCategory(let id):
            return (.GET, "/\(version)/categories/\(id)")
        case .getSubcategories(let id):
            return (.GET, "/\(version)/categories/\(id)/subcategories")
        case .getCategoryItems(let id):
            return (.GET, "/\(version)/categories/\(id)/items")
        case .getItemModifiers(let categoryID, let itemID):
            return (.GET, "/\(version)/categories/\(categoryID)/items/\(itemID)")
        case .getConstructedItemItems(let id):
            return (.GET, "/\(version)/constructedItems/\(id)/items")
        case .getOutstandingOrder(let id):
            return (.GET, "/\(version)/outstandingOrders/\(id)")
        case .getOutstandingOrderConstructedItems(let id):
            return (.GET, "/\(version)/outstandingOrders/\(id)/constructedItems")
        
        case .createUser:
            return (.POST, "/\(version)/users")
        case .createUserCard(let id):
            return (.POST, "/\(version)/users/\(id)/cards")
        case .createUserPurchasedOrder(let id):
            return (.POST, "/\(version)/users/\(id)/purchasedOrders")
        case .createConstructedItem:
            return (.POST, "/\(version)/constructedItems")
        case .addConstructedItemItems(let id):
            return (.POST, "/\(version)/constructedItems/\(id)/items")
        case .createOutstandingOrder:
            return (.POST, "/\(version)/outstandingOrders")
        case .addOutstandingOrderConstructedItems(let id):
            return (.POST, "/\(version)/outstandingOrders/\(id)/constructedItems")
            
        case .updateConstructedItem(let id):
            return (.PUT, "/\(version)/constructedItems/\(id)")
        case .updateOutstandingOrder(let id):
            return (.PUT, "/\(version)/outstandingOrders/\(id)")
            
        case .partiallyUpdateConstructedItem(let id):
            return (.PATCH, "/\(version)/constructedItems/\(id)")
        case .partiallyUpdateOutstandingOrderConstructedItem(let outstandingOrderID, let constructedItemID):
            return (.PATCH, "/\(version)/outstandingOrders/\(outstandingOrderID)/constructedItems/\(constructedItemID)")
            
        case .removeConstructedItemItem(let constructedItemID, let categoryItemID):
            return (.DELETE, "/\(version)/constructedItems/\(constructedItemID)/items/\(categoryItemID)")
        case .removeOutstandingOrderConstructedItem(let outstandingOrderID, let constructedItemID):
            return (.DELETE, "/\(version)/outstandingOrders/\(outstandingOrderID)/constructedItems/\(constructedItemID)")
        }
    }
}
