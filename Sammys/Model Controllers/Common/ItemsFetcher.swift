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
	static var fetcher: ItemsFetcher { get }
}

protocol ItemsFetcher {
	func items(for itemCategory: ItemCategory) -> Promise<[Item]>
}
