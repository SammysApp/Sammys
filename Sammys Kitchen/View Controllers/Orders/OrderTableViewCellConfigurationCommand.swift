//
//  OrderTableViewCellConfigurationCommand.swift
//  Sammys Kitchen
//
//  Created by Natanel Niazoff on 5/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct OrderTableViewCellConfigurationCommand: TableViewCellCommand {
    let kitchenOrder: KitchenOrder
    
    func perform(cell: UITableViewCell?) {
        guard let cell = cell as? OrderTableViewCell else { return }
        cell.numberLabel.text = "#\(kitchenOrder.order.number)"
        cell.nameLabel.text = kitchenOrder.order.userName
        cell.descriptionLabel.text = kitchenOrder.order.itemDescription(for: .salad)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        cell.timeLabel.text = dateFormatter.string(from: kitchenOrder.order.date)
        
        if OrdersReadDataStore.shared.isRead(kitchenOrder) {
            cell.unreadImageView.isHidden = true
        } else {
            cell.unreadImageView.isHidden = false
        }
    }
}
