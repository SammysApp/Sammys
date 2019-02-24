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
    
    private let developmentServer = HTTPServer(urlString: LocalConstants.developmentAPIServerURL)
    private let productionServer = HTTPServer(urlString: "")
    
    var server: HTTPServer {
        switch environment {
        case .development: return developmentServer
        case .production: return productionServer
        }
    }
    
    init(environment: AppEnvironment = appEnvironment) {
        self.environment = environment
    }
    
    func makeGetCategoriesRequest() -> URLRequest {
        return URLRequest(server: server, endpoint: Endpoint.getCategories)!
    }
    
    func makeGetSubcategoriesRequest(parentCategoryID: Category.ID) -> URLRequest {
        return URLRequest(server: server, endpoint: Endpoint.getSubcategories(parentCategoryID))!
    }
}

extension APIURLRequestFactory {
    private enum Endpoint: HTTPEndpoint {
        case getCategories
        case getSubcategories(Category.ID)
        
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
            }
        }
    }
}
