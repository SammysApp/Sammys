//
//  APIURLRequestFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/20/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

struct APIURLRequestFactory {
    private static let defaultJSONEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
    
    private let environment: AppEnvironment
    
    private let developmentServer = HTTPServer(
        scheme: LocalConstants.DevelopmentAPIServer.scheme,
        host: LocalConstants.DevelopmentAPIServer.host,
        port: LocalConstants.DevelopmentAPIServer.port
    )
    
    let defaultJSONDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
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
    
    func makeGetUserCardsRequest(id: User.ID, token: JWT) -> URLRequest {
        return makeRequest(endpoint: .getUserCards(id), token: token)
    }
    
    func makeStoreHoursRequest() -> URLRequest {
        return makeRequest(endpoint: .getStoreHours)
    }
    
    func makeGetCategoriesRequest(queryData: GetCategoriesRequestQueryData? = nil) -> URLRequest {
        return makeRequest(endpoint: .getCategories, queryItems: queryData?.toQueryItems())
    }
    
    func makeGetCategoryRequest(id: Category.ID) -> URLRequest {
        return makeRequest(endpoint: .getCategory(id))
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
    
    func makeGetConstructedItemItems(id: ConstructedItem.ID, queryData: GetConstructedItemItemsRequestQueryData? = nil, token: JWT? = nil) -> URLRequest {
        return makeRequest(endpoint: .getConstructedItemItems(id), queryItems: queryData?.toQueryItems(), token: token)
    }
    
    func makeGetOutstandingOrderRequest(id: OutstandingOrder.ID, token: JWT? = nil) -> URLRequest {
        return makeRequest(endpoint: .getOutstandingOrder(id), token: token)
    }
    
    func makeGetOutstandingOrderConstructedItemsRequest(id: OutstandingOrder.ID, token: JWT? = nil) -> URLRequest {
        return makeRequest(endpoint: .getOutstandingOrderConstructedItems(id), token: token)
    }
    
    func makeGetPurchasedOrdersRequest() -> URLRequest {
        return makeRequest(endpoint: .getPurchasedOrders)
    }
    
    func makeGetPurchasedOrderRequest(id: PurchasedOrder.ID) -> URLRequest {
        return makeRequest(endpoint: .getPurchasedOrder(id))
    }
    
    func makeGetPurchasedOrderConstructedItems(id: PurchasedOrder.ID) -> URLRequest {
        return makeRequest(endpoint: .getPurchasedOrderConstructedItems(id))
    }
    
    func makeGetPurchasedOrderConstructedItemItems(purchasedOrderID: PurchasedOrder.ID, purchasedConstructedItemID: PurchasedConstructedItem.ID) -> URLRequest {
        return makeRequest(endpoint: .getPurchasedOrderConstructedItemItems(purchasedOrderID, purchasedConstructedItemID))
    }
    
    // MARK: - POST
    func makeCreateUserRequest(data: CreateUserRequestData, dataEncoder: JSONEncoder = defaultJSONEncoder, token: JWT) throws -> URLRequest {
        return try makeJSONBodyRequest(endpoint: .createUser, body: dataEncoder.encode(data), token: token)
    }
    
    func makeCreateUserCardRequest(id: User.ID, data: CreateUserCardRequestData, dataEncoder: JSONEncoder = defaultJSONEncoder, token: JWT) throws -> URLRequest {
        return try makeJSONBodyRequest(endpoint: .createUserCard(id), body: dataEncoder.encode(data), token: token)
    }
    
    func makeCreateUserPurchasedOrdersRequest(id: User.ID, data: CreateUserPurchasedOrderRequestData, dataEncoder: JSONEncoder = defaultJSONEncoder, token: JWT) throws -> URLRequest {
        return try makeJSONBodyRequest(endpoint: .createUserPurchasedOrder(id), body: dataEncoder.encode(data), token: token)
    }
    
    func makeCreateConstructedItemRequest(data: CreateConstructedItemRequestData, dataEncoder: JSONEncoder = defaultJSONEncoder, token: JWT? = nil) throws -> URLRequest {
        return try makeJSONBodyRequest(endpoint: .createConstructedItem, body: dataEncoder.encode(data), token: token)
    }
    
    func makeAddConstructedItemItemsRequest(id: ConstructedItem.ID, data: AddConstructedItemItemsRequestData, dataEncoder: JSONEncoder = defaultJSONEncoder, token: JWT? = nil) throws -> URLRequest {
        return try makeJSONBodyRequest(endpoint: .addConstructedItemItems(id), body: dataEncoder.encode(data), token: token)
    }
    
    func makeCreateOutstandingOrderRequest(data: CreateOutstandingOrderRequestData = .init(), dataEncoder: JSONEncoder = defaultJSONEncoder, token: JWT? = nil) throws -> URLRequest {
        return try makeJSONBodyRequest(endpoint: .createOutstandingOrder, body: dataEncoder.encode(data), token: token)
    }
    
    func makeAddOutstandingOrderConstructedItemsRequest(id: OutstandingOrder.ID, data: AddOutstandingOrderConstructedItemsRequestData, dataEncoder: JSONEncoder = defaultJSONEncoder, token: JWT? = nil) throws -> URLRequest {
        return try makeJSONBodyRequest(endpoint: .addOutstandingOrderConstructedItems(id), body: dataEncoder.encode(data), token: token)
    }
    
    // MARK: - PUT
    func makeUpdateConstructedItemRequest(id: ConstructedItem.ID, data: ConstructedItem, dataEncoder: JSONEncoder = defaultJSONEncoder, token: JWT? = nil) throws -> URLRequest {
        return try makeJSONBodyRequest(endpoint: .updateConstructedItem(id), body: dataEncoder.encode(data), token: token)
    }
    
    func makeUpdateOutstandingOrderRequest(id: OutstandingOrder.ID, data: OutstandingOrder, dataEncoder: JSONEncoder = defaultJSONEncoder, token: JWT? = nil) throws -> URLRequest {
        return try makeJSONBodyRequest(endpoint: .updateOutstandingOrder(id), body: dataEncoder.encode(data), token: token)
    }
    
    // MARK: - PATCH
    func makePartiallyUpdateConstructedItemRequest(id: ConstructedItem.ID, data: PartiallyUpdateConstructedItemRequestData, dataEncoder: JSONEncoder = defaultJSONEncoder, token: JWT? = nil) throws -> URLRequest {
        return try makeJSONBodyRequest(endpoint: .partiallyUpdateConstructedItem(id), body: dataEncoder.encode(data), token: token)
    }
    
    func makePartiallyUpdateOutstandingOrderConstructedItemRequest(outstandingOrderID: OutstandingOrder.ID, constructedItemID: ConstructedItem.ID, data: PartiallyUpdateOutstandingOrderConstructedItemRequestData, dataEncoder: JSONEncoder = defaultJSONEncoder, token: JWT? = nil) throws -> URLRequest {
        return try makeJSONBodyRequest(endpoint: .partiallyUpdateOutstandingOrderConstructedItem(outstandingOrderID, constructedItemID), body: dataEncoder.encode(data), token: token)
    }
    
    func makePartiallyUpdatePurchasedOrderRequest(id: PurchasedOrder.ID, data: PartiallyUpdatePurchasedOrderRequestData, dataEncoder: JSONEncoder = defaultJSONEncoder) throws -> URLRequest {
        return try makeJSONBodyRequest(endpoint: .partiallyUpdatePurchasedOrder(id), body: dataEncoder.encode(data))
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

struct GetConstructedItemItemsRequestQueryData {
    var categoryID: Category.ID?
    
    init(categoryID: Category.ID? = nil) {
        self.categoryID = categoryID
    }
    
    func toQueryItems() -> [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        if let categoryID = categoryID {
            queryItems.append(URLQueryItem(name: "categoryID", value: categoryID.uuidString))
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

struct CreateUserCardRequestData: Codable {
    let cardNonce: String
    let postalCode: String
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

struct PartiallyUpdatePurchasedOrderRequestData: Codable {
    let progress: OrderProgress
}
