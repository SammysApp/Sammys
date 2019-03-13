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
    /// GET `/categories`
    case getCategories
    /// GET `/categories/:category/subcategories`
    case getSubcategories(Category.ID)
    /// GET `/categories/:category/item`
    case getCategoryItems(Category.ID)
    /// GET `/categories/:category/item/:item/modifiers`
    case getItemModifiers(Category.ID, Item.ID)
    /// GET /outstandingOrders/:outstandingOrder
    case getOutstandingOrder(OutstandingOrder.ID)
    /// GET /outstandingOrders/:outstandingOrder/constructedItems
    case getOutstandingOrderConstructedItems(OutstandingOrder.ID)
    
    // MARK: - POST
    /// POST `/constructedItems`
    case createConstructedItem
    /// POST `/constructedItems/:constructedItem/items`
    case addConstructedItemItems(ConstructedItem.ID)
    /// POST `/outstandingOrders`
    case createOutstandingOrder
    /// POST `/outstandingOrders/:outstandingOrder/constructedItems`
    case addOutstandingOrderConstructedItems(OutstandingOrder.ID)
    
    // MARK: - PATCH
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
        case .getCategories:
            return (.GET, "/\(version)/categories")
        case .getSubcategories(let id):
            return (.GET, "/\(version)/categories/\(id)/subcategories")
        case .getCategoryItems(let id):
            return (.GET, "/\(version)/categories/\(id)/items")
        case .getItemModifiers(let categoryID, let itemID):
            return (.GET, "/\(version)/categories/\(categoryID)/items/\(itemID)")
        case .getOutstandingOrder(let id):
            return (.GET, "/\(version)/outstandingOrders/\(id)")
        case .getOutstandingOrderConstructedItems(let id):
            return (.GET, "/\(version)/outstandingOrders/\(id)/constructedItems")
            
        case .createConstructedItem:
            return (.POST, "/\(version)/constructedItems")
        case .addConstructedItemItems(let id):
            return (.POST, "/\(version)/constructedItems/\(id)/items")
        case .createOutstandingOrder:
            return (.POST, "/\(version)/outstandingOrders")
        case .addOutstandingOrderConstructedItems(let id):
            return (.POST, "/\(version)/outstandingOrders/\(id)/constructedItems")
            
        case .partiallyUpdateOutstandingOrderConstructedItem(let outstandingOrderID, let constructedItemID):
            return (.PATCH, "/\(version)/outstandingOrders/\(outstandingOrderID)/constructedItems/\(constructedItemID)")
            
        case .removeConstructedItemItem(let constructedItemID, let categoryItemID):
            return (.DELETE, "/\(version)/constructedItems/\(constructedItemID)/items/\(categoryItemID)")
        case .removeOutstandingOrderConstructedItem(let outstandingOrderID, let constructedItemID):
            return (.DELETE, "/\(version)/outstandingOrders/\(outstandingOrderID)/constructedItems/\(constructedItemID)")
        }
    }
}
