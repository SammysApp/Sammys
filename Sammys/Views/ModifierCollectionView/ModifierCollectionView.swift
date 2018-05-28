//
//  ModifierCollectionView.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/24/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class ModifierCollectionView: UICollectionView, ModifierCollectionViewModelDelegate {
    let viewModel = ModifierCollectionViewModel()
    
    private var modifierDataSource: ModifierCollectionViewDataSource!
    private var modifierDelegate: ModifierCollectionViewDelegate!
    
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
        modifierDataSource = ModifierCollectionViewDataSource(viewModel: viewModel)
        modifierDelegate = ModifierCollectionViewDelegate(viewModel: viewModel)
        dataSource = modifierDataSource
        delegate = modifierDelegate
        viewModel.delegate = self
    }
    
    func needsUpdate() {
        reloadData()
    }
}

class ModifierCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    private var viewModel: ModifierCollectionViewModel!
    
    convenience init(viewModel: ModifierCollectionViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    private override init() {
        super.init()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems(inSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "modifierCell", for: indexPath) as! ModifierCollectionViewCell
        cell.titleLabel.text = viewModel.titleText(for: indexPath)
        cell.priceLabel.isHidden = viewModel.shouldHidePriceLabel(for: indexPath)
        cell.priceLabel.text = viewModel.priceLabelText(for: indexPath)
        cell.contentView.backgroundColor = viewModel.backgroundColor(for: indexPath)
        return cell
    }
}

class ModifierCollectionViewDelegate: NSObject, UICollectionViewDelegateFlowLayout {
    private var viewModel: ModifierCollectionViewModel!
    
    convenience init(viewModel: ModifierCollectionViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    private override init() {
        super.init()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel.sizeForItem(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return viewModel.insetForSection(at: section, withContextBounds: collectionView.bounds)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectItem(at: indexPath)
    }
}
