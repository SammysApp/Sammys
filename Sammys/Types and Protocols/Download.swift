//
//  Download.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/24/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

enum Download<Source, Value> {
    case willDownload(Source)
    case downloading
    case completed(Result)
    
    enum Result {
        case success(Value)
        case failure(Error)
    }
}
