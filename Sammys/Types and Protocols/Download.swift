//
//  DownloadState.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/24/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

enum DownloadState<Source, Download, Value> {
    case willDownload(Source)
    case downloading(Download)
    case completed(Result)
    
    enum Result {
        case success(Value)
        case failure(Error)
    }
}

class Download<Source, Download, Value> {
    let id: UUID
    var state: Dynamic<DownloadState<Source, Download, Value>>
    
    init(id: UUID = UUID(), source: Source) {
        self.id = id
        self.state = Dynamic(.willDownload(source))
    }
}
