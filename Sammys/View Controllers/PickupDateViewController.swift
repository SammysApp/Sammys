//
//  PickupDateViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 6/10/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol PickupDateViewControllerDelegate {
    
}

class PickupDateViewController: UIViewController {
    let viewModel = PickupDateViewModel()
    let formatter = DateFormatter()
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var pickupNowButton: UIButton!
    @IBOutlet var dayPickerView: UIPickerView!
    
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
        //let date = Date()
    }
    
    @IBAction func datePickerValueDidChange(_ sender: UIDatePicker) {
        let dateComponents: Set<Calendar.Component> = [.month, .day, .hour, .minute]
        let isPickupNow = Calendar.current.dateComponents(dateComponents, from: sender.date) == Calendar.current.dateComponents(dateComponents, from: Date())
        dateLabel.text = isPickupNow ? Constants.pickupNow : formatter.string(from: sender.date)
        pickupNowButton.isHidden = isPickupNow
    }
    
    @IBAction func didTapPickupNow(_ sender: UIButton) {
        
    }
}

extension PickupDateViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func pickerViewKey(for pickerView: UIPickerView) -> PickerViewKey? {
        switch pickerView {
        case dayPickerView: return .day
        default: return nil
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        guard let pickerViewKey = pickerViewKey(for: pickerView) else { fatalError() }
        return viewModel.numberOfComponents(for: pickerViewKey)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let pickerViewKey = pickerViewKey(for: pickerView) else { fatalError() }
        return viewModel.numberOfRows(inComponent: component, for: pickerViewKey)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let pickerViewKey = pickerViewKey(for: pickerView) else { fatalError() }
        return viewModel.title(forRow: row, inComponent: component, for: pickerViewKey)
    }
}

extension PickupDateViewController: Storyboardable {
    typealias ViewController = PickupDateViewController
}
