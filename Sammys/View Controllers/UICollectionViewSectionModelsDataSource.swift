//
//  UICollectionViewSectionModelsDataSource.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/26/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class UICollectionViewSectionModelsDataSource: NSObject, UICollectionViewDataSource {
    var sectionModels: [UICollectionViewSectionModel]
    
    init(sectionModels: [UICollectionViewSectionModel] = []) {
        self.sectionModels = sectionModels
        super.init()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionModels[section].cellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellViewModel = sectionModels.cellViewModel(for: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellViewModel.identifier, for: indexPath)
        cellViewModel.perform(.configuration, indexPath: indexPath, cell: cell)
        return cell
    }
}
