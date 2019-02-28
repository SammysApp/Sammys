//
//  ConstructedItemViewControllerTests.swift
//  SammysTests
//
//  Created by Natanel Niazoff on 2/28/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import XCTest
@testable import Sammys

class ConstructedItemViewControllerTests: XCTestCase {
    let viewController = ConstructedItemViewController()
    
    override func setUp() {
        viewController.viewModel.categoryID = UUID()
    }
    
    func testCategories() throws {
        let categories = [
            Category(id: Category.ID(), name: "A", isConstructable: false),
            Category(id: Category.ID(), name: "B", isConstructable: false),
            Category(id: Category.ID(), name: "C", isConstructable: false)
        ]
        let categoriesData = try JSONEncoder().encode(categories)
        viewController.viewModel.httpClient = MockHTTPClient { request in
            return HTTPResponse(statusCode: 200, data: categoriesData)
        }
        viewController.viewDidLoad()
        let expectation = XCTestExpectation()
        if let download = viewController.viewModel.categoriesDownload,
            case .downloading(let promise) = download {
            promise.asVoid().get {
                XCTAssert(self.viewController.categoryCollectionView.numberOfItems(inSection: 0) == categories.count)
                expectation.fulfill()
            }.cauterize()
        }
    }
}
