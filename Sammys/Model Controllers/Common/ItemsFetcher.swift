//
//  ItemsFetcher.swift
//  Sammys
//
//  Created by Natanel Niazoff on 10/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import PromiseKit

protocol ItemsFetchable {
	static var fetcher: ItemsFetcher.Type { get }
}

protocol ItemsFetcher {
	static func getItems(for itemCategory: ItemCategory) -> Promise<[Item]>
}
