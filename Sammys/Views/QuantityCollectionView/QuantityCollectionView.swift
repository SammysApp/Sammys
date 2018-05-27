//
//  QuantityCollectionView.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/26/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

enum QuantityCellIdentifier: String {
    case quantityCell
}

/// A collection view displaying quantities for an item.
class QuantityCollectionView: UICollectionView {
    private var quantityDataSource: QuantityCollectionViewDataSource!
    private var quantityDelegate: QuantityCollectionViewDelegate!
    
    var viewModel = QuantityCollectionViewModel() {
        didSet {
            updateViewModel()
        }
    }
    
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
        updateViewModel()
        
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = .greatestFiniteMagnitude
        }
        alwaysBounceHorizontal = true
        backgroundColor = .clear
    }
    
    func updateViewModel() {
        quantityDataSource = QuantityCollectionViewDataSource(viewModel: viewModel)
        quantityDelegate = QuantityCollectionViewDelegate(viewModel: viewModel)
        dataSource = quantityDataSource
        delegate = quantityDelegate
    }
}

class QuantityCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    var viewModel: QuantityCollectionViewModel!
    
    convenience init(viewModel: QuantityCollectionViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems(inSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QuantityCellIdentifier.quantityCell.rawValue, for: indexPath) as! QuantityCollectionViewCell
        cell.numberLabel.text = "\(indexPath.row)"
        cell.numberLabel.textColor = viewModel.textColor
        if viewModel.indexPathShouldShowDelete(indexPath) {
            cell.numberLabel.isHidden = true
            cell.deleteImage.isHidden = false
            cell.contentView.backgroundColor = viewModel.deleteBackgroundColor
        } else {
            cell.numberLabel.isHidden = false
            cell.deleteImage.isHidden = true
            cell.contentView.backgroundColor = viewModel.backgroundColor
        }
        return cell
    }
}

class QuantityCollectionViewDelegate: NSObject, UICollectionViewDelegateFlowLayout {
    var viewModel: QuantityCollectionViewModel!
    
    convenience init(viewModel: QuantityCollectionViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.layer.masksToBounds = false
        cell.add(UIView.Shadow(path: UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath, radius: 5, opacity: 0.15))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.height - 20
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath)
    }
}
