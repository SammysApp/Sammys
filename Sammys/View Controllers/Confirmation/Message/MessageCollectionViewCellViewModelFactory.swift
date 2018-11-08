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

struct MessageCollectionViewCellViewModelFactory/*: CollectionViewCellViewModelFactory*/ {
    let size: CGSize
    let order: Order
    
//    func create() -> DefaultCollectionViewCellViewModel {
//        let configurationCommand = MessageCollectionViewCellConfigurationCommand(order: order)
//        let selectionCommand = MessageCollectionViewCellSelectionCommand()
//        return DefaultCollectionViewCellViewModel(identifier: MessageCellIdentifier.messageCell.rawValue, size: size, commands: [.configuration: configurationCommand, .selection: selectionCommand])
//    }
}
