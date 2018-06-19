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
        let isOrderScheduled = kitchenOrder.order.pickupDate != nil
        
        cell.numberLabel.text = "#\(kitchenOrder.order.number)"
        cell.nameLabel.text = kitchenOrder.order.userName
        cell.descriptionLabel.text = kitchenOrder.order.itemDescription(for: .salad)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        cell.timeLabel.text = dateFormatter.string(from: isOrderScheduled ? kitchenOrder.order.pickupDate! : kitchenOrder.order.date)
        let currentTimeLabelFontSize = cell.timeLabel.font.pointSize
        cell.timeLabel.font = UIFont.systemFont(ofSize: currentTimeLabelFontSize, weight: isOrderScheduled ? .bold : .regular)
        cell.timeLabel.textColor = isOrderScheduled ? #colorLiteral(red: 1, green: 0, blue: 0.2615994811, alpha: 1) : .lightGray
        cell.pickupLabel.isHidden = !isOrderScheduled
        
        cell.unreadImageView.isHidden = UserDataStore.shared.isRead(kitchenOrder)
    }
}
