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
    
    // MARK: - GET
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
    func makeCreateConstructedItemRequest(data: CreateConstructedItemData, dataEncoder: JSONEncoder = JSONEncoder()) throws -> URLRequest {
        var request = URLRequest(server: server, endpoint: APIEndpoint.createConstructedItem, headers: [HTTPHeader(name: .contentType, value: .json)]) ?? preconditionFailure()
        request.httpBody = try dataEncoder.encode(data)
        return request
    }
    
    func makeAddConstructedItemItemsRequest(id: ConstructedItem.ID, data: AddConstructedItemItemsData, dataEncoder: JSONEncoder = JSONEncoder()) throws -> URLRequest {
        var request = URLRequest(server: server, endpoint: APIEndpoint.addConstructedItemItems(id), headers: [HTTPHeader(name: .contentType, value: .json)]) ?? preconditionFailure()
        request.httpBody = try dataEncoder.encode(data)
        return request
    }
    
    func makeCreateOutstandingOrderRequest(data: CreateOutstandingOrderData, dataEncoder: JSONEncoder = JSONEncoder()) throws -> URLRequest {
        var request = URLRequest(server: server, endpoint: APIEndpoint.createOutstandingOrder, headers: [HTTPHeader(name: .contentType, value: .json)]) ?? preconditionFailure()
        request.httpBody = try dataEncoder.encode(data)
        return request
    }
    
    func makeAddOutstandingOrderConstructedItemsRequest(id: OutstandingOrder.ID, data: AddOutstandingOrderConstructedItemsData, dataEncoder: JSONEncoder = JSONEncoder()) throws -> URLRequest {
        var request = URLRequest(server: server, endpoint: APIEndpoint.addOutstandingOrderConstructedItems(id), headers: [HTTPHeader(name: .contentType, value: .json)]) ?? preconditionFailure()
        request.httpBody = try dataEncoder.encode(data)
        return request
    }
    
    // MARK: - PATCH
    func makePartiallyUpdateOutstandingOrderConstructedItemRequest(outstandingOrderID: OutstandingOrder.ID, constructedItemID: ConstructedItem.ID, data: PartiallyUpdateOutstandingOrderConstructedItemData, dataEncoder: JSONEncoder = JSONEncoder()) throws -> URLRequest {
        var request = URLRequest(server: server, endpoint: APIEndpoint.partiallyUpdateOutstandingOrderConstructedItem(outstandingOrderID, constructedItemID), headers: [HTTPHeader(name: .contentType, value: .json)]) ?? preconditionFailure()
        request.httpBody = try dataEncoder.encode(data)
        return request
    }
    
    // MARK: - DELETE
    func makeRemoveConstructedItemItemsRequest(constructedItemID: ConstructedItem.ID, categoryItemID: Item.CategoryItemID) -> URLRequest {
        return URLRequest(server: server, endpoint: APIEndpoint.removeConstructedItemItem(constructedItemID, categoryItemID)) ?? preconditionFailure()
    }
    
    func makeRemoveOutstandingOrderConstructedItem(outstandingOrderID: OutstandingOrder.ID, constructedItemID: ConstructedItem.ID) -> URLRequest {
        return URLRequest(server: server, endpoint: APIEndpoint.removeOutstandingOrderConstructedItem(outstandingOrderID, constructedItemID)) ?? preconditionFailure()
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

struct CreateOutstandingOrderData: Codable {}

struct AddOutstandingOrderConstructedItemsData: Codable {
    let ids: [ConstructedItem.ID]
}

struct PartiallyUpdateOutstandingOrderConstructedItemData: Codable {
    let quantity: Int?
}
