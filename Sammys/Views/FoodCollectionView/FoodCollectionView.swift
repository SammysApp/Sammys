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
//    var viewModel: FoodCollectionViewModel? {
//        didSet {
//            if let viewModel = viewModel { update(with: viewModel) }
//        }
//    }
//    private var foodDataSource: FoodCollectionViewDataSource!
//    private var foodDelegate: FoodCollectionViewDelegate!
//    
//    private struct Constants {
//        static let itemCollectionViewCellNibName = "ItemCollectionViewCell"
//    }
//    
//    convenience init(frame: CGRect, viewModel: FoodCollectionViewModel) {
//        self.init(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
//        self.viewModel = viewModel
//        setup(viewModel)
//    }
//    
//    private override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
//        super.init(frame: frame, collectionViewLayout: layout)
//        setup()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        setup()
//    }
//    
//    private func setup(_ viewModel: FoodCollectionViewModel? = nil) {
//        backgroundColor = #colorLiteral(red: 1, green: 0.968627451, blue: 0.9411764706, alpha: 1)
//        alwaysBounceVertical = true
//        
//        register(UINib(nibName: Constants.itemCollectionViewCellNibName, bundle: Bundle.main), forCellWithReuseIdentifier: ItemCellIdentifier.itemCell.rawValue)
//        register(FoodHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: FoodReuseIdentifier.header.rawValue)
//        
//        if let viewModel = viewModel { update(with: viewModel) }
//    }
//    
//    private func update(with viewModel: FoodCollectionViewModel) {
//        foodDataSource = FoodCollectionViewDataSource(viewModel: viewModel)
//        foodDelegate = FoodCollectionViewDelegate(viewModel: viewModel)
//        dataSource = foodDataSource
//        delegate = foodDelegate
//    }
//}
//
//class FoodCollectionViewDataSource: NSObject, UICollectionViewDataSource {
//    var viewModel: FoodCollectionViewModel!
//    
//    convenience init(viewModel: FoodCollectionViewModel) {
//        self.init()
//        self.viewModel = viewModel
//    }
//    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return viewModel.numberOfSections
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return viewModel.numberOfItems(inSection: section)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FoodReuseIdentifier.itemCell.rawValue, for: indexPath) as! ItemCollectionViewCell
//        cell.backgroundColor = #colorLiteral(red: 0.3333333333, green: 0.3019607843, blue: 0.2745098039, alpha: 1)
//        cell.layer.cornerRadius = 20
//        
//        cell.titleLabel.text = viewModel.title(for: indexPath)
//        cell.descriptionLabel.text = viewModel.descriptionText(for: indexPath)
//        cell.descriptionLabel.isHidden = viewModel.descriptionLabelShouldHide(for: indexPath)
//        cell.priceLabel.text = viewModel.priceText(for: indexPath)
//        cell.priceLabel.isHidden = viewModel.priceLabelShouldHide(for: indexPath)
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        if kind == UICollectionElementKindSectionHeader {
//            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: FoodReuseIdentifier.header.rawValue, for: indexPath) as! FoodHeaderView
//            headerView.titleLabel.text = viewModel.headerTitle(for: indexPath)
//            headerView.leftInset = viewModel.cellSpacing
//            headerView.showsEdit = viewModel.showsEdit
//            headerView.didTapEdit = { headerView in self.viewModel.didTapEdit(for: indexPath) }
//            return headerView
//        }
//        return UICollectionReusableView()
//    }
//}
//
//class FoodCollectionViewDelegate: NSObject, UICollectionViewDelegateFlowLayout {
//    var viewModel: FoodCollectionViewModel!
//    
//    convenience init(viewModel: FoodCollectionViewModel) {
//        self.init()
//        self.viewModel = viewModel
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return viewModel.sizeForItem(at: indexPath, withContextBounds: collectionView.frame)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(width: collectionView.frame.width, height: viewModel.headerHeight)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return viewModel.insetForSection(at: section)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return viewModel.cellSpacing
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return viewModel.cellSpacing
//    }
}
