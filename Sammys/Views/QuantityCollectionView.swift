//
//  QuantityCollectionView.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/26/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

enum Quantity {
    case none
    case some(Int)
}

enum QuantityCellIdentifier: String {
    case quantityCell
}

/// A collection view displaying quantities for an item.
class QuantityCollectionView: UICollectionView {
    var didSelectQuantity: ((Quantity) -> Void)?
    
    convenience init(frame: CGRect) {
        self.init(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    private override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = .greatestFiniteMagnitude
        }
        backgroundColor = .white
        alwaysBounceHorizontal = true
        
        dataSource = self
        delegate = self
    }
}

extension QuantityCollectionView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QuantityCellIdentifier.quantityCell.rawValue, for: indexPath) as! QuantityCollectionViewCell
        cell.numberLabel.text = "\(indexPath.row)"
        cell.numberLabel.textColor = .white
        cell.backgroundColor = .flora
        cell.layer.cornerRadius = 10
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.height - 20
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            didSelectQuantity?(.none)
        default:
            didSelectQuantity?(.some(indexPath.row))
        }
    }
}
