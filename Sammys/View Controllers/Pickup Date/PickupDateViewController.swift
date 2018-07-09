//
//  PickupDateViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 6/10/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol PickupDateViewControllerDelegate: class {
    func pickupDateViewController(_ pickupDateViewController: PickupDateViewController, didSelect pickupDate: PickupDate)
    func pickupDateViewControllerDidFinish(_ pickupDateViewController: PickupDateViewController)
}

class PickupDateViewController: UIViewController, Blurable {
    let viewModel = PickupDateViewModel()
    weak var delegate: PickupDateViewControllerDelegate?
    
    @IBOutlet var backgroundView: UIVisualEffectView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var pickupASAPButton: UIButton!
    @IBOutlet var datePickerView: UIPickerView!
    
    var blurView: UIVisualEffectView {
        return backgroundView
    }
    let blurEffect = UIBlurEffect(style: .light)
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeBlurView()
        
        viewModel.delegate = self
        startUpdateDatePickerTimer()
        
        updateUI()
    }
    
    func updateUI() {
        dateLabel.text = viewModel.dateLabelText
        pickupASAPButton.isHidden = viewModel.shouldHidePickupASAPButton
    }
    
    func startUpdateDatePickerTimer() {
        updateDatePickerView()
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
            self.updateDatePickerView()
        }.fire()
    }
    
    func updateDatePickerView() {
        viewModel.startDate = Date()
    }
    
    func resetDatePickerView() {
        viewModel.resetComponents()
        for component in 0..<viewModel.componentsCount {
            datePickerView.selectRow(0, inComponent: component, animated: true)
        }
    }
    
    @IBAction func didTapView(_ sender: UITapGestureRecognizer) {
        delegate?.pickupDateViewControllerDidFinish(self)
    }
    
    @IBAction func didTapPickupASAP(_ sender: UIButton) {
        resetDatePickerView()
        viewModel.wantsPickupASAP = true
    }
}

extension PickupDateViewController: PickupDateViewModelDelegate {
    func needsUIUpdate() {
        updateUI()
    }
    
    func datePickerViewNeedsUpdate() {
        datePickerView.reloadAllComponents()
    }
    
    func datePickerViewNeedsUpdate(forComponent component: Int) {
        datePickerView.reloadComponent(component)
    }
    
    func datePickerSelectedRow(inComponent component: Int) -> Int {
        return datePickerView.selectedRow(inComponent: component)
    }
    
    func didSelect(_ pickupDate: PickupDate) {
        delegate?.pickupDateViewController(self, didSelect: pickupDate)
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
