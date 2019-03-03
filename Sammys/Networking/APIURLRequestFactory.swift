//
//  APIURLRequestFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/20/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

struct APIURLRequestFactory {
    private let environment: AppEnvironment
    
    private let developmentServer = HTTPServer(host: LocalConstants.DevelopmentAPIServer.host, port: LocalConstants.DevelopmentAPIServer.port)
    private let productionServer = HTTPServer(host: "")
    
    var server: HTTPServer {
        switch environment {
        case .development: return developmentServer
        case .production: return productionServer
        }
    }
    
    init(environment: AppEnvironment = appEnvironment) {
        self.environment = environment
    }
    
    func makeGetCategoriesRequest(queryItems: [URLQueryItem] = []) -> URLRequest {
        return URLRequest(server: server, endpoint: Endpoint.getCategories, queryItems: queryItems) ?? preconditionFailure()
    }
    
    func makeGetSubcategoriesRequest(parentCategoryID: Category.ID) -> URLRequest {
        return URLRequest(server: server, endpoint: Endpoint.getSubcategories(parentCategoryID)) ?? preconditionFailure()
    }
    
    func makeGetCategoryItemsRequest(id: Category.ID) -> URLRequest {
        return URLRequest(server: server, endpoint: Endpoint.getCategoryItems(id)) ?? preconditionFailure()
    }
    
    func makeGetItemModifiersRequest(categoryID: Category.ID, itemID: Item.ID) -> URLRequest {
        return URLRequest(server: server, endpoint: Endpoint.getItemModifiers(categoryID, itemID)) ?? preconditionFailure()
    }
    
    func makeCreateConstructedItemRequest(data: CreateConstructedItemData, dataEncoder: JSONEncoder = JSONEncoder()) throws -> URLRequest {
        var urlRequest = URLRequest(server: server, endpoint: Endpoint.createConstructedItem, headers: [HTTPHeader(name: .contentType, value: .json)]) ?? preconditionFailure()
        urlRequest.httpBody = try dataEncoder.encode(data)
        return urlRequest
    }
    
    func makeAddConstructedItemItemsRequest(id: ConstructedItem.ID, data: AddConstructedItemItemsData, dataEncoder: JSONEncoder = JSONEncoder()) throws -> URLRequest {
        var urlRequest = URLRequest(server: server, endpoint: Endpoint.addConstructedItemItems(id), headers: [HTTPHeader(name: .contentType, value: .json)]) ?? preconditionFailure()
        urlRequest.httpBody = try dataEncoder.encode(data)
        return urlRequest
    }
}

private extension APIURLRequestFactory {
    enum Endpoint: HTTPEndpoint {
        // MARK: - GET
        /// GET `/categories`
        case getCategories
        /// GET `/categories/:category/subcategories`
        case getSubcategories(Category.ID)
        /// GET `/categories/:category/item`
        case getCategoryItems(Category.ID)
        /// GET `/categories/:category/item/:item/modifiers`
        case getItemModifiers(Category.ID, Item.ID)
        
        // MARK: - POST
        /// POST `/constructedItems`
        case createConstructedItem
        /// POST `/constructedItems/:constructedItem/items`
        case addConstructedItemItems(ConstructedItem.ID)
        
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
            case .createConstructedItem:
                return (.POST, "/\(version)/constructedItems")
            case .addConstructedItemItems(let id):
                return (.POST, "/\(version)/constructedItems/\(id)/items")
            }
        }
    }
}

struct CreateConstructedItemData: Codable {
    let categoryID: Category.ID
    
    init(categoryID: Category.ID) {
        self.categoryID = categoryID
    }
}

struct AddConstructedItemItemsData: Codable {
    let categoryItemIDs: [UUID]
}
