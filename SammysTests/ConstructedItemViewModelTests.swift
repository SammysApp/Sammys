//
//  ConstructedItemViewModelTests.swift
//  SammysTests
//
//  Created by Natanel Niazoff on 3/6/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import XCTest
@testable import Sammys

class ConstructedItemViewModelTests: XCTestCase {
    private let viewModel = ConstructedItemViewModel()
    
    override func setUp() {
        continueAfterFailure = false
        viewModel.errorHandler = { XCTFail($0.localizedDescription) }
    }
    
    override func tearDown() {
        viewModel.categoryID = nil
        viewModel.constructedItemID = nil
    }
    
    func testBeginReturnStoredOutstandingOrdersDownload() throws {
        let returnStoredExpectation = XCTestExpectation()
        guard let id1 = OutstandingOrder.ID(uuidString: "D1016A67-7A86-4430-9B91-C871FC0F5E13"),
            let id2 = OutstandingOrder.ID(uuidString: "800EB171-F4E0-4ADE-8041-E0176FEB625A")
            else { return }
        let storedOutstandingOrderIDs = [id1, id2]
        
        viewModel.keyValueStore = MockReturnStoredOutstandingOrdersKeyValueStore(storedIDs: storedOutstandingOrderIDs)
        viewModel.beginOutstandingOrdersDownload { ids in
            XCTAssertEqual(ids, storedOutstandingOrderIDs)
            returnStoredExpectation.fulfill()
        }
        
        wait(for: [returnStoredExpectation], timeout: 10.0)
    }
    
    func testBeginCreateNewOutstandingOrdersDownload() throws {
        viewModel.categoryID = Category.ID()
        viewModel.constructedItemID = ConstructedItem.ID()
        
        let createNewExpectation = XCTestExpectation()
        guard let newOutstandingOrderID = OutstandingOrder.ID(uuidString: "480E290C-C50C-4A95-B4D5-59302E05493C")
            else { return }
        let newOutstandingOrder = OutstandingOrder(id: newOutstandingOrderID)
        let newOutstandingOrderData = try JSONEncoder().encode(newOutstandingOrder)
        
        viewModel.httpClient = MockHTTPClient { request in
            return HTTPResponse(statusCode: 200, data: newOutstandingOrderData)
        }
        viewModel.keyValueStore = MockCreateNewOutstandingOrdersKeyValueStore(newID: newOutstandingOrderID)
        viewModel.beginOutstandingOrdersDownload { ids in
            XCTAssertEqual(ids, [newOutstandingOrderID])
            createNewExpectation.fulfill()
        }
        
        wait(for: [createNewExpectation], timeout: 10.0)
    }
}

private struct MockReturnStoredOutstandingOrdersKeyValueStore: KeyValueStore {
    let storedIDs: [OutstandingOrder.ID]
    
    func set<Element>(_ value: [Element], forKey key: KeyValueStoreKey) {}
    
    func array<Element>(of elementType: Element.Type, forKey key: KeyValueStoreKey) -> [Element]? {
        guard let elements = storedIDs as? [Element] else { XCTFail(); fatalError() }
        return elements
    }
}

private struct MockCreateNewOutstandingOrdersKeyValueStore: KeyValueStore {
    let newID: OutstandingOrder.ID
    
    func set<Element>(_ value: [Element], forKey key: KeyValueStoreKey) {
        if let outstandingOrderIDs = value as? [OutstandingOrder.ID] {
            XCTAssertEqual(outstandingOrderIDs, [newID])
        } else { XCTFail() }
    }
    
    func array<Element>(of elementType: Element.Type, forKey key: KeyValueStoreKey) -> [Element]? {
        return nil
    }
}
