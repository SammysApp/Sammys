//
//  UICollectionViewSectionModelsDelegate.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/26/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class UICollectionViewSectionModelsDelegate: NSObject, UICollectionViewDelegate {
    var sectionModels: [UICollectionViewSectionModel]
    
    init(sectionModels: [UICollectionViewSectionModel] = []) {
        self.sectionModels = sectionModels
        super.init()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        sectionModels.cellViewModel(for: indexPath).perform(.selection, indexPath: indexPath)
    }
}

class UICollectionViewSectionModelsDelegateFlowLayout: UICollectionViewSectionModelsDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellViewModel = sectionModels.cellViewModel(for: indexPath)
        let size = cellViewModel.sizeHandler?(.init(cellViewModel: cellViewModel, indexPath: indexPath)) ?? cellViewModel.size
        return CGSize(width: size.width, height: size.height)
    }
}
