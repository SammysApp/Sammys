//
//  APIURLRequestFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/20/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

struct APIURLRequestFactory {
    private let environment: AppEnvironment
    
    private let developmentServer = HTTPServer(
        host: LocalConstants.DevelopmentAPIServer.host,
        port: LocalConstants.DevelopmentAPIServer.port
    )
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
    
    // MARK: - GET
    func makeGetUserRequest(id: User.ID, token: JWT) -> URLRequest {
        return URLRequest(server: server, endpoint: APIEndpoint.getUser(id), headers: [HTTPHeader(name: .authorization, value: .bearerAuthentication(token))]) ?? preconditionFailure()
    }
    
    func makeGetTokenUserRequest(token: JWT) -> URLRequest {
        return URLRequest(server: server, endpoint: APIEndpoint.getTokenUser, headers: [HTTPHeader(name: .authorization, value: .bearerAuthentication(token))]) ?? preconditionFailure()
    }
    
    func makeGetCategoriesRequest(queryItems: [URLQueryItem] = []) -> URLRequest {
        return URLRequest(server: server, endpoint: APIEndpoint.getCategories, queryItems: queryItems) ?? preconditionFailure()
    }
    
    func makeGetSubcategoriesRequest(parentCategoryID: Category.ID) -> URLRequest {
        return URLRequest(server: server, endpoint: APIEndpoint.getSubcategories(parentCategoryID)) ?? preconditionFailure()
    }
    
    func makeGetCategoryItemsRequest(id: Category.ID) -> URLRequest {
        return URLRequest(server: server, endpoint: APIEndpoint.getCategoryItems(id)) ?? preconditionFailure()
    }
    
    func makeGetItemModifiersRequest(categoryID: Category.ID, itemID: Item.ID) -> URLRequest {
        return URLRequest(server: server, endpoint: APIEndpoint.getItemModifiers(categoryID, itemID)) ?? preconditionFailure()
    }
    
    func makeGetOutstandingOrderRequest(id: OutstandingOrder.ID) -> URLRequest {
        return URLRequest(server: server, endpoint: APIEndpoint.getOutstandingOrder(id)) ?? preconditionFailure()
    }
    
    func makeGetOutstandingOrderConstructedItemsRequest(id: OutstandingOrder.ID) -> URLRequest {
        return URLRequest(server: server, endpoint: APIEndpoint.getOutstandingOrderConstructedItems(id)) ?? preconditionFailure()
    }
    
    // MARK: - POST
    func makeCreateUserRequest(data: CreateUserData, dataEncoder: JSONEncoder = JSONEncoder(), token: JWT) throws -> URLRequest {
        var request = URLRequest(
            server: server,
            endpoint: APIEndpoint.createUser,
            headers: [
                HTTPHeader(name: .contentType, value: .json),
                HTTPHeader(name: .authorization, value: .bearerAuthentication(token))
            ]
        ) ?? preconditionFailure()
        request.httpBody = try dataEncoder.encode(data)
        return request
    }
    
    func makeCreateConstructedItemRequest(data: CreateConstructedItemData, dataEncoder: JSONEncoder = JSONEncoder(), token: JWT? = nil) throws -> URLRequest {
        var request = URLRequest(server: server, endpoint: APIEndpoint.createConstructedItem, headers: [HTTPHeader(name: .contentType, value: .json)]) ?? preconditionFailure()
        if let token = token { request.add(HTTPHeader(name: .authorization, value: .bearerAuthentication(token))) }
        request.httpBody = try dataEncoder.encode(data)
        return request
    }
    
    func makeAddConstructedItemItemsRequest(id: ConstructedItem.ID, data: AddConstructedItemItemsData, dataEncoder: JSONEncoder = JSONEncoder(), token: JWT? = nil) throws -> URLRequest {
        var request = URLRequest(server: server, endpoint: APIEndpoint.addConstructedItemItems(id), headers: [HTTPHeader(name: .contentType, value: .json)]) ?? preconditionFailure()
        if let token = token { request.add(HTTPHeader(name: .authorization, value: .bearerAuthentication(token))) }
        request.httpBody = try dataEncoder.encode(data)
        return request
    }
    
    func makeCreateOutstandingOrderRequest(data: CreateOutstandingOrderData, dataEncoder: JSONEncoder = JSONEncoder(), token: JWT? = nil) throws -> URLRequest {
        var request = URLRequest(server: server, endpoint: APIEndpoint.createOutstandingOrder, headers: [HTTPHeader(name: .contentType, value: .json)]) ?? preconditionFailure()
        request.httpBody = try dataEncoder.encode(data)
        if let token = token { request.add(HTTPHeader(name: .authorization, value: .bearerAuthentication(token))) }
        return request
    }
    
    func makeAddOutstandingOrderConstructedItemsRequest(id: OutstandingOrder.ID, data: AddOutstandingOrderConstructedItemsData, dataEncoder: JSONEncoder = JSONEncoder(), token: JWT? = nil) throws -> URLRequest {
        var request = URLRequest(server: server, endpoint: APIEndpoint.addOutstandingOrderConstructedItems(id), headers: [HTTPHeader(name: .contentType, value: .json)]) ?? preconditionFailure()
        request.httpBody = try dataEncoder.encode(data)
        if let token = token { request.add(HTTPHeader(name: .authorization, value: .bearerAuthentication(token))) }
        return request
    }
    
    // MARK: - PUT
    func makeUpdateConstructedItemRequest(id: ConstructedItem.ID, data: ConstructedItem, dataEncoder: JSONEncoder = JSONEncoder()) throws -> URLRequest {
        var request = URLRequest(server: server, endpoint: APIEndpoint.updateConstructedItem(id), headers: [HTTPHeader(name: .contentType, value: .json)]) ?? preconditionFailure()
        request.httpBody = try dataEncoder.encode(data)
        return request
    }
    
    // MARK: - PATCH
    func makePartiallyUpdateConstructedItemRequest(id: ConstructedItem.ID, data: PartiallyUpdateConstructedItemData, dataEncoder: JSONEncoder = JSONEncoder(), token: JWT? = nil) throws -> URLRequest {
        var request = URLRequest(server: server, endpoint: APIEndpoint.partiallyUpdateConstructedItem(id), headers: [HTTPHeader(name: .contentType, value: .json)]) ?? preconditionFailure()
        if let token = token { request.add(HTTPHeader(name: .authorization, value: .bearerAuthentication(token))) }
        request.httpBody = try dataEncoder.encode(data)
        return request
    }
    
    func makePartiallyUpdateOutstandingOrderConstructedItemRequest(outstandingOrderID: OutstandingOrder.ID, constructedItemID: ConstructedItem.ID, data: PartiallyUpdateOutstandingOrderConstructedItemData, dataEncoder: JSONEncoder = JSONEncoder()) throws -> URLRequest {
        var request = URLRequest(
            server: server,
            endpoint: APIEndpoint.partiallyUpdateOutstandingOrderConstructedItem(outstandingOrderID, constructedItemID),
            headers: [HTTPHeader(name: .contentType, value: .json)]
        ) ?? preconditionFailure()
        request.httpBody = try dataEncoder.encode(data)
        return request
    }
    
    // MARK: - DELETE
    func makeRemoveConstructedItemItemsRequest(constructedItemID: ConstructedItem.ID, categoryItemID: Item.CategoryItemID, token: JWT? = nil) -> URLRequest {
        var request = URLRequest(server: server, endpoint: APIEndpoint.removeConstructedItemItem(constructedItemID, categoryItemID)) ?? preconditionFailure()
        if let token = token { request.add(HTTPHeader(name: .authorization, value: .bearerAuthentication(token))) }
        return request
    }
    
    func makeRemoveOutstandingOrderConstructedItem(outstandingOrderID: OutstandingOrder.ID, constructedItemID: ConstructedItem.ID) -> URLRequest {
        return URLRequest(server: server, endpoint: APIEndpoint.removeOutstandingOrderConstructedItem(outstandingOrderID, constructedItemID)) ?? preconditionFailure()
    }
}

struct CreateUserData: Codable {
    let email: String
    let firstName: String
    let lastName: String
}

struct CreateConstructedItemData: Codable {
    let categoryID: Category.ID
    let userID: User.ID?
    
    init(categoryID: Category.ID,
         userID: User.ID? = nil) {
        self.categoryID = categoryID
        self.userID = userID
    }
}

struct AddConstructedItemItemsData: Codable {
    let categoryItemIDs: [UUID]
}

struct CreateOutstandingOrderData: Codable {
    let userID: User.ID?
}

struct AddOutstandingOrderConstructedItemsData: Codable {
    let ids: [ConstructedItem.ID]
}

struct PartiallyUpdateConstructedItemData: Codable {
    let userID: User.ID?
    let isFavorite: Bool?
    
    init(userID: User.ID? = nil,
         isFavorite: Bool? = nil) {
        self.userID = userID
        self.isFavorite = isFavorite
    }
}

struct PartiallyUpdateOutstandingOrderConstructedItemData: Codable {
    let quantity: Int?
}
