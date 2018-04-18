//
//  MessageCollectionViewCellViewModelFactory.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/16/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

enum MessageCellIdentifier: String {
    case messageCell
}

struct MessageCollectionViewCellViewModelFactory: CollectionViewCellViewModelFactory {
    private let size: CGSize
    
    init(size: CGSize) {
        self.size = size
    }
    
    func create() -> CollectionViewCellViewModel {
        let configurationCommand = MessageCollectionViewCellConfigurationCommand()
        let selectionCommand = MessageCollectionViewCellSelectionCommand()
        return CollectionViewCellViewModel(identifier: MessageCellIdentifier.messageCell.rawValue, size: size, commands: [.configuration: configurationCommand, .selection: selectionCommand])
    }
}
