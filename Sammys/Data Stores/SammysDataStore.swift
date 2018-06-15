//
//  SammysDataStore.swift
//  Sammys
//
//  Created by Natanel Niazoff on 6/14/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

class SammysDataStore {
    static let shared = SammysDataStore()
    
    var hours: [Hours]?
    
    private init() {}
    
    func setHours(completed: ((_ hours: [Hours]) -> Void)? = nil) {
        DataAPIClient.getHours { result in
            switch result {
            case .success(let hours):
                self.hours = hours
                completed?(hours)
            case .failure(_): break
            }
        }
    }
}
