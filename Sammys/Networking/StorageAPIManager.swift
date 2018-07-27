//
//  StorageAPIManager.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/21/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import FirebaseStorage

struct StorageAPIManager {
    private static let storage = Storage.storage().reference()
    
    private struct Constants {
        static let oneMB: Int64 = 1024 * 1024
    }
    
    enum ImageAPIResult {
        case success(UIImage)
        case failure(Error)
    }
    
    enum ImageAPIError: Error {
        case badData
    }
    
    private static func getImage(_ reference: StorageReference, maxSize: Int64, completed: @escaping (ImageAPIResult) -> ()) {
        reference.getData(maxSize: maxSize) { (data, error) in
            if let error = error {
                completed(.failure(error))
            } else {
                guard let data = data, let image = UIImage(data: data) else {
                        completed(.failure(ImageAPIError.badData))
                        return
                }
                completed(.success(image))
            }
        }
    }
}
