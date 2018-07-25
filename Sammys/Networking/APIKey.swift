//
//  APIKey.swift
//  Sammys
//
//  Created by Natanel Niazoff on 6/21/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

private let apiKeysFileName = "APIKeys"

enum APIProvider: String {
    case stripePublishableLive = "STRIPE_PUBLISHABLE_LIVE"
    case stripePublishableTest = "STRIPE_PUBLISHABLE_TEST"
    case microsoftTranslator = "MICROSOFT_TRANSLATOR"
}

func apiKey(for service: APIProvider) -> String {
    guard let path = Bundle.main.path(forResource: apiKeysFileName, ofType: FileType.plist.rawValue) else { fatalError("An APIKeys.plist file is missing from the project! Create a plist with the neccessary API services keys.") }
    guard let apiKeys = NSDictionary(contentsOfFile: path), let apiKey = apiKeys.value(forKey: service.rawValue) as? String else { fatalError("An error occured grabbing the proper API key for the service. Please make sure everything is set up right!") }
    return apiKey
}
