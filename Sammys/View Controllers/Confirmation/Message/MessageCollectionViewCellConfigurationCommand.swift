//
//  MessageCollectionViewCellConfigurationCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/16/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct MessageCollectionViewCellConfigurationCommand: CollectionViewCellCommand {
    func perform(parameters: CommandParameters) {
        guard let cell = parameters.cell as? MessageCollectionViewCell else { return }
        cell.messageTextView.text = "Your order will be ready in 15 minutes. We can't wait to see you!"
    }
}
