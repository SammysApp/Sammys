//
//  FoodCollectionView.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/12/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import UIKit

/**
 Implement this protocol to handle changes and updates to a FoodCollectionView.
*/
protocol FoodCollectionViewDelegate {
    func didTapEdit(for title: String)
}

class FoodCollectionView: UICollectionView {
    var foodDelegate: FoodCollectionViewDelegate?
    
    private var food: Food!
    var dictionary: Food.ItemsDictionary {
        return food.itemDictionary
    }
    
    convenience init(frame: CGRect, food: Food) {
        self.init(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        self.food = food
    }
    
    private override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        backgroundColor = UIColor(named: "Snow")
        alwaysBounceVertical = true
        
        register(ItemCollectionViewCell.self, forCellWithReuseIdentifier: "itemCell")
        register(FoodHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        
        dataSource = self
        delegate = self
    }
}

extension FoodCollectionView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dictionary.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dictionary[section]?.items.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as! ItemCollectionViewCell
        cell.backgroundColor = UIColor(named: "Flora")
        cell.layer.cornerRadius = 20
        cell.titleLabel.text = dictionary[indexPath.section]?.items[indexPath.row].name ?? nil
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! FoodHeaderView
            headerView.titleLabel.text = dictionary[indexPath.section]?.title ?? nil
            headerView.delegate = self
            return headerView
        default: return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.width/2 - 15
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

extension FoodCollectionView: FoodHeaderViewDelegate {
    func didTapEdit(in headerView: FoodHeaderView) {
        if let title = headerView.titleLabel.text {
            foodDelegate?.didTapEdit(for: title)
        }
    }
}
