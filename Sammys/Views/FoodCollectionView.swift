//
//  FoodCollectionView.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/12/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import UIKit

enum FoodReuseIdentifier: String {
    case itemCell, header
}

/// A collection view displaying food details.
class FoodCollectionView: UICollectionView {
    private var foodDataSource: FoodCollectionViewDataSource!
    private var foodDelegate: FoodCollectionViewDelegate!
    
    convenience init(frame: CGRect, viewModel: FoodCollectionViewModel) {
        self.init(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        self.foodDataSource = FoodCollectionViewDataSource(viewModel: viewModel)
        self.foodDelegate = FoodCollectionViewDelegate(viewModel: viewModel)
        self.dataSource = foodDataSource
        self.delegate = foodDelegate
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
        backgroundColor = .snow
        alwaysBounceVertical = true
        
        register(ItemCollectionViewCell.self, forCellWithReuseIdentifier: FoodReuseIdentifier.itemCell.rawValue)
        register(FoodHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: FoodReuseIdentifier.header.rawValue)
    }
}

class FoodCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    var viewModel: FoodCollectionViewModel!
    
    convenience init(viewModel: FoodCollectionViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.sections[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FoodReuseIdentifier.itemCell.rawValue, for: indexPath) as! ItemCollectionViewCell
        cell.backgroundColor = .flora
        cell.layer.cornerRadius = 20
        cell.titleLabel.text = viewModel.sections[indexPath.section].items[indexPath.row].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let section = viewModel.sections[indexPath.section]
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: FoodReuseIdentifier.header.rawValue, for: indexPath) as! FoodHeaderView
            headerView.titleLabel.text = section.title
            headerView.didTapEdit = { headerView in
                self.viewModel.didTapEdit?(section.type)
            }
            return headerView
        default: return UICollectionReusableView()
        }
    }
}

class FoodCollectionViewDelegate: NSObject, UICollectionViewDelegateFlowLayout {
    var viewModel: FoodCollectionViewModel!
    
    convenience init(viewModel: FoodCollectionViewModel) {
        self.init()
        self.viewModel = viewModel
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
