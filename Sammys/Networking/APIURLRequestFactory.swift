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
        return URLRequest(server: server, endpoint: Endpoint.getCategories, queryItems: queryItems)!
    }
    
    func makeGetSubcategoriesRequest(parentCategoryID: Category.ID) -> URLRequest {
        return URLRequest(server: server, endpoint: Endpoint.getSubcategories(parentCategoryID))!
    }
    
    func makeGetCategoryItemsRequest(categoryID: Category.ID) -> URLRequest {
        return URLRequest(server: server, endpoint: Endpoint.getCategoryItems(categoryID))!
    }
    
    func makeGetItemModifiersRequest(categoryID: Category.ID, itemID: Item.ID) -> URLRequest {
        return URLRequest(server: server, endpoint: Endpoint.getItemModifiers(categoryID, itemID))!
    }
}

extension APIURLRequestFactory {
    private enum Endpoint: HTTPEndpoint {
        /// `/categories`
        case getCategories
        /// `/categories/:category/subcategories`
        case getSubcategories(Category.ID)
        /// `/categories/:category/item`
        case getCategoryItems(Category.ID)
        /// `/categories/:category/item/:item/modifiers`
        case getItemModifiers(Category.ID, Item.ID)
        
        private enum Version: String {
            case v1
        }
        
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
            }
        }
    }
}
