//
//  TranslationAPIClient.swift
//  Sammys
//
//  Created by Natanel Niazoff on 6/21/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import Alamofire

enum LanguageCode: String {
    case en, es
}

struct TranslationAPIClient {
    static let baseURL = "https://api.cognitive.microsofttranslator.com/translate"
    
    static func translate(_ stringToTranslate: String, from fromLanguageCode: LanguageCode, to toLanguageCode: LanguageCode, didComplete: @escaping (String) -> Void) {
        guard let url = URL(string: baseURL + "?api-version=3.0" + "&from=\(fromLanguageCode.rawValue)" + "&to=\(toLanguageCode.rawValue)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("f710d17f80dd4ec599d0f3d36c01dbb6", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do { request.httpBody = try JSONSerialization.data(withJSONObject: [["Text": stringToTranslate]]) } catch { return }
        Alamofire.request(request).responseJSON { response in
            if let jsonData = response.data {
                if let translationData = try? JSONDecoder().decode([TranslationData].self, from: jsonData) {
                    if let translation = translationData.first?.translations.first?.text {
                        didComplete(translation)
                    }
                }
            }
        }
    }
}

struct TranslationData: Decodable {
    let translations: [Translation]
    
    struct Translation: Decodable {
        let text: String
        let to: String
    }
}
