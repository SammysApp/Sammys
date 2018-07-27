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
    
    func setHours(didComplete: ((_ hours: [Hours]) -> Void)? = nil) {
        DataAPIManager.getHours()
            .get { self.hours = $0; didComplete?($0) }
            .catch { print($0) }
    }
}
