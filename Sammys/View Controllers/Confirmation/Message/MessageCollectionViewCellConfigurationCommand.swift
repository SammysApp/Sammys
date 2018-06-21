//
//  MessageCollectionViewCellConfigurationCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/16/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct MessageCollectionViewCellConfigurationCommand: CollectionViewCellCommand {
    let order: Order
    
    private struct Constants {
        static let titleText = "Sammy's has recieved your order. ☺️"
        static let dateFormat = "EEEE, MMMM d"
        static let timeFormat = "h:mm a"
    }
    
    func perform(parameters: CommandParameters) {
        guard let cell = parameters.cell as? MessageCollectionViewCell else { return }
        // Configure cell UI.
        ConfirmationViewController.configureUI(for: cell)
        cell.contentView.backgroundColor = #colorLiteral(red: 0.9800000191, green: 0.9800000191, blue: 0.9800000191, alpha: 1)
        cell.titleLabel.text = Constants.titleText
        var readyTimeString = "ASAP"
        if let date = order.pickupDate {
            readyTimeString = "at \(timeString(for: date)) on \(dayString(for: date))"
        }
        cell.messageLabel.text = "Your order will be ready \(readyTimeString). Just look for a bag with your name, \(order.userName), on it by the salad station. We can't wait to see you!"
    }
    
    func dayString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        return formatter.string(from: date) + date.daySuffix
    }
    
    func timeString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.timeFormat
        return formatter.string(from: date)
    }
}
