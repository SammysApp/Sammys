//
//  FoodCollectionViewDataSource.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/12/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import UIKit

class FoodCollectionViewDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var food: Food
    var data: [String : [Item]] {
        var data: [String: [Item]] = [:]
        switch food {
        case let salad as Salad:
            let mirroredSalad = Mirror(reflecting: salad)
            for child in mirroredSalad.children {
                if let propertyName = child.label {
                    switch child.value {
                    case let item as [Item]:
                        data[propertyName] = item
                    case let item as Item:
                        data[propertyName] = [item]
                    default: break
                    }
                }
            }
            fallthrough
        default:
            return data
        }
    }
    
    init(food: Food) {
        self.food = food
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data[Array(data.keys)[section]]?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .purple
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}
