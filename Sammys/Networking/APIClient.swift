//
//  APIClient.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/20/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

struct APIClient {
    private static var serverURL: String {
        switch environment {
        case .development: return LocalConstants.developmentAPIServerURL
        case .production: return Constants.serverURL
        }
    }
    
    private let server = HTTPServer(urlString: serverURL)
    private let httpClient: HTTPClient
    
    private struct Constants {
        static let serverURL = ""
        static let version = "v1"
    }
    
    private enum Endpoints: HTTPEndpoint {
        case getCategories
        case getSubcategories(Category.ID)
        
        var endpoint: (HTTPMethod, URLPath) {
            switch self {
            case .getCategories:
                return (.GET, "/\(Constants.version)/categories")
            case .getSubcategories(let id):
                return (.GET, "/\(Constants.version)/categories/\(id)/subcategories")
            }
        }
    }
    
    init(httpClient: HTTPClient = URLSessionHTTPClient()) {
        self.httpClient = httpClient
    }
    
    func getCategories() throws -> Promise<[Category]> {
        return try httpClient.send(Endpoints.getCategories, to: server)
            .validate()
            .map { try JSONDecoder().decode([Category].self, from: $0.data) }
    }
    
    func getSubcategories(of categoryID: Category.ID) throws -> Promise<[Category]> {
        return try httpClient.send(Endpoints.getSubcategories(categoryID), to: server)
            .validate()
            .map { try JSONDecoder().decode([Category].self, from: $0.data) }
    }
}
