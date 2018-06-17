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

class PickupDateViewController: UIViewController, Blurable {
    let viewModel = PickupDateViewModel()
    let formatter = DateFormatter()
    
    @IBOutlet var backgroundView: UIVisualEffectView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var pickupNowButton: UIButton!
    @IBOutlet var datePickerView: UIPickerView!
    
    var blurView: UIVisualEffectView {
        return backgroundView
    }
    let blurEffect = UIBlurEffect(style: .light)
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    struct Constants {
        static let pickupNow = "Pickup Now"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        formatter.dateFormat = "MM/dd h:mm a"
        startUpdateDatePickerTimer()
    }
    
    func startUpdateDatePickerTimer() {
        updateDatePickerView()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.updateDatePickerView()
        }
    }
    
    func updateDatePickerView() {
        
    }
    
    @IBAction func didTapPickupNow(_ sender: UIButton) {
        
    }
}

extension PickupDateViewController: PickupDateViewModelDelegate {
    func datePickerViewNeedsUpdate() {
        datePickerView.reloadAllComponents()
    }
    
    func datePickerViewNeedsUpdate(for component: Int) {
        datePickerView.reloadComponent(component)
    }
}

extension PickupDateViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return viewModel.numberOfComponents
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.numberOfRows(inComponent: component)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.title(forRow: row, inComponent: component)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.handleDidSelectRow(row, inComponent: component)
    }
}

extension PickupDateViewController: Storyboardable {
    typealias ViewController = PickupDateViewController
}
