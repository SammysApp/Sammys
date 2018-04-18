//
//  MapCollectionViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/13/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

private enum MapCellIdentifier: String {
    case mapCell
}

struct MapCollectionViewCellViewModelFactory: CollectionViewCellViewModelFactory {
    private let size: CGSize
    
    init(size: CGSize) {
        self.size = size
    }
    
    func create() -> CollectionViewCellViewModel {
        let configurationCommand = MapCollectionViewCellConfigurationCommand()
        let selectionCommand = MapCollectionViewCellSelectionCommand()
        return CollectionViewCellViewModel(identifier: MapCellIdentifier.mapCell.rawValue, size: size, commands: [.configuration: configurationCommand, .selection: selectionCommand])
    }
}
