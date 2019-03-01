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
        let categoriesExpectation = XCTestExpectation()
        guard let download = viewController.viewModel.categoriesDownload,
            case .downloading(let categoriesDownloadPromise) = download else { preconditionFailure() }
        categoriesDownloadPromise.asVoid().get {
            XCTAssert(self.viewController.categoryCollectionView.numberOfItems(inSection: 0) == categories.count)
            categoriesExpectation.fulfill()
        }.catch { XCTFail($0.localizedDescription) }
    }
    
    func testSelectItem() throws {
        viewController.viewModel.constructedItemID = UUID()
        guard let categoryItemID = UUID(uuidString: "2619ffbd-c278-4cb6-8f1e-a25d0170edad") else { preconditionFailure() }
        let items = [Item(id: Item.ID(), name: "A", categoryItemID: categoryItemID)]
        let itemsData = try JSONEncoder().encode(items)
        let itemAddedExpectation = XCTestExpectation()
        viewController.viewModel.httpClient = MockHTTPClient { request in
            guard let methodString = request.httpMethod, let method = HTTPMethod(rawValue: methodString)
                else { preconditionFailure() }
            switch method {
            case .GET: return HTTPResponse(statusCode: 200, data: itemsData)
            case .POST:
                guard let rawData = request.httpBody else { XCTFail("No body data."); fatalError() }
                do {
                    let data = try JSONDecoder().decode(AddConstructedItemItemsData.self, from: rawData)
                    XCTAssert(categoryItemID == data.categoryItemIDs[0])
                    itemAddedExpectation.fulfill()
                } catch { XCTFail(error.localizedDescription) }
                fallthrough
            default: return HTTPResponse(statusCode: 200, data: Data())
            }
        }
        viewController.viewDidLoad()
        viewController.viewModel.selectedCategoryID.value = UUID()
        guard let download = viewController.itemsViewController.viewModel.itemsDownload,
            case .downloading(let itemsDownloadPromise) = download else { preconditionFailure() }
        itemsDownloadPromise.asVoid().get {
            let tableView = self.viewController.itemsViewController.tableView
            tableView.delegate?.tableView?(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        }.catch { XCTFail($0.localizedDescription) }
    }
}
