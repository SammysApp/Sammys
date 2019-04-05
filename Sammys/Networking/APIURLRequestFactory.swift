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
    
    var server: HTTPServer {
        switch environment {
        case .development: return developmentServer
        // FIXME: Add production server.
        case .production: preconditionFailure()
        }
    }
    
    init(environment: AppEnvironment = appEnvironment) {
        self.environment = environment
    }
    
    private func makeRequest(endpoint: APIEndpoint, queryItems: [URLQueryItem]? = nil, token: JWT? = nil) -> URLRequest {
        var request = URLRequest(server: server, endpoint: endpoint, queryItems: queryItems) ?? preconditionFailure()
        if let token = token {
            request.add(HTTPHeader(name: .authorization, value: .bearerAuthentication(token)))
        }
        return request
    }
    
    private func makeJSONBodyRequest(endpoint: APIEndpoint, queryItems: [URLQueryItem]? = nil, body: Data, token: JWT? = nil) -> URLRequest {
        var request = makeRequest(endpoint: endpoint, queryItems: queryItems, token: token)
        request.add(HTTPHeader(name: .contentType, value: .json))
        request.httpBody = body
        return request
    }
    
    // MARK: - GET
    func makeGetTokenUserRequest(token: JWT) -> URLRequest {
        return makeRequest(endpoint: .getTokenUser, token: token)
    }
    
    func makeGetUserRequest(id: User.ID, token: JWT) -> URLRequest {
        return makeRequest(endpoint: .getUser(id), token: token)
    }
    
    func makeGetUserOutstandingOrdersRequest(id: User.ID, token: JWT) -> URLRequest {
        return makeRequest(endpoint: .getUserOutstandingOrders(id), token: token)
    }
    
    func makeStoreHoursRequest() -> URLRequest {
        return makeRequest(endpoint: .getStoreHours)
    }
    
    func makeGetCategoriesRequest(queryData: GetCategoriesRequestQueryData? = nil) -> URLRequest {
        return makeRequest(endpoint: .getCategories, queryItems: queryData?.toQueryItems())
    }
    
    func makeGetSubcategoriesRequest(parentCategoryID: Category.ID) -> URLRequest {
        return makeRequest(endpoint: .getSubcategories(parentCategoryID))
    }
    
    func makeGetCategoryItemsRequest(id: Category.ID) -> URLRequest {
        return makeRequest(endpoint: .getCategoryItems(id))
    }
    
    func makeGetItemModifiersRequest(categoryID: Category.ID, itemID: Item.ID) -> URLRequest {
        return makeRequest(endpoint: .getItemModifiers(categoryID, itemID))
    }
    
    func makeGetOutstandingOrderRequest(id: OutstandingOrder.ID, token: JWT? = nil) -> URLRequest {
        return makeRequest(endpoint: .getOutstandingOrder(id), token: token)
    }
    
    func makeGetOutstandingOrderConstructedItemsRequest(id: OutstandingOrder.ID, token: JWT? = nil) -> URLRequest {
        return makeRequest(endpoint: .getOutstandingOrderConstructedItems(id), token: token)
    }
    
    // MARK: - POST
    func makeCreateUserRequest(data: CreateUserRequestData, dataEncoder: JSONEncoder = JSONEncoder(), token: JWT) throws -> URLRequest {
        return makeJSONBodyRequest(endpoint: .createUser, body: try dataEncoder.encode(data), token: token)
    }
    
    func makeCreateUserPurchasedOrdersRequest(id: User.ID, data: CreateUserPurchasedOrderRequestData, dataEncoder: JSONEncoder = JSONEncoder(), token: JWT) throws -> URLRequest {
        return makeJSONBodyRequest(endpoint: .createUserPurchasedOrder(id), body: try dataEncoder.encode(data), token: token)
    }
    
    func makeCreateConstructedItemRequest(data: CreateConstructedItemRequestData, dataEncoder: JSONEncoder = JSONEncoder(), token: JWT? = nil) throws -> URLRequest {
        return makeJSONBodyRequest(endpoint: .createConstructedItem, body: try dataEncoder.encode(data), token: token)
    }
    
    func makeAddConstructedItemItemsRequest(id: ConstructedItem.ID, data: AddConstructedItemItemsRequestData, dataEncoder: JSONEncoder = JSONEncoder(), token: JWT? = nil) throws -> URLRequest {
        return makeJSONBodyRequest(endpoint: .addConstructedItemItems(id), body: try dataEncoder.encode(data), token: token)
    }
    
    func makeCreateOutstandingOrderRequest(data: CreateOutstandingOrderRequestData = .init(), dataEncoder: JSONEncoder = JSONEncoder(), token: JWT? = nil) throws -> URLRequest {
        return makeJSONBodyRequest(endpoint: .createOutstandingOrder, body: try dataEncoder.encode(data), token: token)
    }
    
    func makeAddOutstandingOrderConstructedItemsRequest(id: OutstandingOrder.ID, data: AddOutstandingOrderConstructedItemsRequestData, dataEncoder: JSONEncoder = JSONEncoder(), token: JWT? = nil) throws -> URLRequest {
        return makeJSONBodyRequest(endpoint: .addOutstandingOrderConstructedItems(id), body: try dataEncoder.encode(data), token: token)
    }
    
    // MARK: - PUT
    func makeUpdateConstructedItemRequest(id: ConstructedItem.ID, data: ConstructedItem, dataEncoder: JSONEncoder = JSONEncoder(), token: JWT? = nil) throws -> URLRequest {
        return makeJSONBodyRequest(endpoint: .updateConstructedItem(id), body: try dataEncoder.encode(data), token: token)
    }
    
    // MARK: - PATCH
    func makePartiallyUpdateConstructedItemRequest(id: ConstructedItem.ID, data: PartiallyUpdateConstructedItemRequestData, dataEncoder: JSONEncoder = JSONEncoder(), token: JWT? = nil) throws -> URLRequest {
        return makeJSONBodyRequest(endpoint: .partiallyUpdateConstructedItem(id), body: try dataEncoder.encode(data), token: token)
    }
    
    func makePartiallyUpdateOutstandingOrderConstructedItemRequest(outstandingOrderID: OutstandingOrder.ID, constructedItemID: ConstructedItem.ID, data: PartiallyUpdateOutstandingOrderConstructedItemRequestData, dataEncoder: JSONEncoder = JSONEncoder(), token: JWT? = nil) throws -> URLRequest {
        return makeJSONBodyRequest(endpoint: .partiallyUpdateOutstandingOrderConstructedItem(outstandingOrderID, constructedItemID), body: try dataEncoder.encode(data), token: token)
    }
    
    // MARK: - DELETE
    func makeRemoveConstructedItemItemsRequest(constructedItemID: ConstructedItem.ID, categoryItemID: Item.CategoryItemID, token: JWT? = nil) -> URLRequest {
        return makeRequest(endpoint: .removeConstructedItemItem(constructedItemID, categoryItemID), token: token)
    }
    
    func makeRemoveOutstandingOrderConstructedItem(outstandingOrderID: OutstandingOrder.ID, constructedItemID: ConstructedItem.ID, token: JWT? = nil) -> URLRequest {
        return makeRequest(endpoint: .removeOutstandingOrderConstructedItem(outstandingOrderID, constructedItemID), token: token)
    }
}

struct GetCategoriesRequestQueryData {
    var isRoot: Bool?
    
    init(isRoot: Bool? = nil) {
        self.isRoot = isRoot
    }
    
    func toQueryItems() -> [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        if let isRoot = isRoot {
            queryItems.append(URLQueryItem(name: "isRoot", value: String(isRoot)))
        }
        return queryItems
    }
}

struct CreateUserRequestData: Codable {
    let email: String
    let firstName: String
    let lastName: String
}

struct CreateUserPurchasedOrderRequestData: Codable {
    let outstandingOrderID: OutstandingOrder.ID
    let cardNonce: String?
    let customerCardID: String?
}

struct CreateConstructedItemRequestData: Codable {
    let categoryID: Category.ID
    let userID: User.ID?
    
    init(categoryID: Category.ID,
         userID: User.ID? = nil) {
        self.categoryID = categoryID
        self.userID = userID
    }
}

struct AddConstructedItemItemsRequestData: Codable {
    let categoryItemIDs: [UUID]
}

struct CreateOutstandingOrderRequestData: Codable {
    let userID: User.ID?
    
    init(userID: User.ID? = nil) {
        self.userID = userID
    }
}

struct AddOutstandingOrderConstructedItemsRequestData: Codable {
    let ids: [ConstructedItem.ID]
}

struct PartiallyUpdateConstructedItemRequestData: Codable {
    let userID: User.ID?
    let isFavorite: Bool?
    
    init(userID: User.ID? = nil,
         isFavorite: Bool? = nil) {
        self.userID = userID
        self.isFavorite = isFavorite
    }
}

struct PartiallyUpdateOutstandingOrderConstructedItemRequestData: Codable {
    let quantity: Int?
}
