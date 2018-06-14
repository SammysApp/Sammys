//
//  OrderTableViewCellSelectionCommand.swift
//  Sammys Kitchen
//
//  Created by Natanel Niazoff on 6/3/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct OrderTableViewCellSelectionCommand: TableViewCellCommand {
    let kitchenOrder: KitchenOrder
    
    func perform(cell: UITableViewCell?) {
        guard let cell = cell as? OrderTableViewCell else { return }
        cell.unreadImageView.isHidden = true
        
        UserDataStore.shared.setRead(kitchenOrder)
    }
}
