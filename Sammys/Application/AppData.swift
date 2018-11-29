//
//  AppData.swift
//  Sammys
//
//  Created by Natanel Niazoff on 11/29/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum AppDataError: Error {
	case couldNotFindFile
}

struct AppData: Codable {
	let sammys: Sammys
	
	struct Sammys: Codable {
		let latitude: Double
		let longitude: Double
	}
}

extension AppData {
	static func get(in bundle: Bundle = .main) throws -> AppData {
		guard let path = bundle.path(forResource: String(describing: AppData.self), ofType: FileType.plist.rawValue) else { throw AppDataError.couldNotFindFile }
		return try PropertyListDecoder().decode(AppData.self, from: Data(contentsOf: URL(fileURLWithPath: path)))
	}
}
