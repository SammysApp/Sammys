//
//  MapCollectionViewCellSelectionCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/18/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct MapCollectionViewCellSelectionCommand: CollectionViewCellCommand {
    func perform(parameters: CommandParameters) {
        guard let viewController = parameters.viewController as? ConfirmationViewController else { return }
        viewController.presentNavigationAlert()
    }
}
