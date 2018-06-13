//
//  OrderDateViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 6/10/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol OrderDateViewControllerDelegate {
    
}

class OrderDateViewController: UIViewController {
    let formatter = DateFormatter()
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var pickupNowButton: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    struct Constants {
        static let pickupNow = "Pickup Now"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatter.dateFormat = "MM/dd h:mm a"
        startUpdateDatePickerTimer()
    }
    
    func startUpdateDatePickerTimer() {
        updateDatePicker()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.updateDatePicker()
        }
    }
    
    func updateDatePicker() {
        let date = Date()
        datePicker.minimumDate = date
        datePicker.maximumDate = Calendar.current.date(byAdding: .month, value: 1, to: date)
    }
    
    @IBAction func datePickerValueDidChange(_ sender: UIDatePicker) {
        let dateComponents: Set<Calendar.Component> = [.month, .day, .hour, .minute]
        let isPickupNow = Calendar.current.dateComponents(dateComponents, from: sender.date) == Calendar.current.dateComponents(dateComponents, from: Date())
        dateLabel.text = isPickupNow ? Constants.pickupNow : formatter.string(from: sender.date)
        pickupNowButton.isHidden = isPickupNow
    }
    
    @IBAction func didTapPickupNow(_ sender: UIButton) {
        datePicker.setDate(Date(), animated: true)
        datePickerValueDidChange(datePicker)
    }
}

extension OrderDateViewController: Storyboardable {
    typealias ViewController = OrderDateViewController
}
