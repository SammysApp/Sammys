//
//  OrdersViewController.swift
//  Sammys Kitchen
//
//  Created by Natanel Niazoff on 5/31/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import SwiftySound
import AVFoundation

class OrdersViewController: UIViewController {
    let viewModel = OrdersViewModel()
    static let storyboardID = "ordersViewController"
    var alertSound: Sound?
    
    // MARK: - IBOutlets & View Properties
    @IBOutlet var tableView: UITableView!
    @IBOutlet var nothingView: UIView! {
        didSet {
            nothingView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    @IBOutlet var nothingLabel: UILabel!
    @IBOutlet var dateButton: UIButton! {
        didSet {
            dateButton.layer.cornerRadius = dateButton.frame.height/2
        }
    }
    @IBOutlet var datePickerView: UIVisualEffectView! {
        didSet {
            datePickerView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var todayButton: UIButton!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    
    var datePickerViewEffect = UIBlurEffect(style: .light)
    
    lazy var nothingViewConstraints = [
        nothingView.leftAnchor.constraint(equalTo: view.leftAnchor),
        nothingView.topAnchor.constraint(equalTo: view.topAnchor),
        nothingView.rightAnchor.constraint(equalTo: view.rightAnchor),
        nothingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ]
    lazy var datePickerViewConstraints = [
        datePickerView.leftAnchor.constraint(equalTo: view.leftAnchor),
        datePickerView.topAnchor.constraint(equalTo: view.topAnchor),
        datePickerView.rightAnchor.constraint(equalTo: view.rightAnchor),
        datePickerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ]
    
    private struct Constants {
        static let alertFileName = "Alert"
        static let alertNumberOfLoops = 2
        static let alertMessage = "there's a new order"
    }
    
    private enum SegueIdentifier: String {
        case showFood
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        updateTitle()
        tableView.separatorInset.left = 30
        tableView.separatorColor = #colorLiteral(red: 0.8901960784, green: 0.862745098, blue: 0.8352941176, alpha: 1)
        splitViewController?.view.backgroundColor = #colorLiteral(red: 0.3960784314, green: 0.3568627451, blue: 0.3215686275, alpha: 1)
        dateButton.isHidden = viewModel.dateButtonShouldHide
        
        if let url = Bundle.main.url(forResource: Constants.alertFileName, withExtension: FileExtension.wav.rawValue),
            let sound = Sound(url: url) {
            alertSound = sound
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //clearsSelectionOnViewWillAppear = splitViewController?.isCollapsed ?? false
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.handleViewDidAppear()
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        viewModel.handleViewDidDisappear()
        super.viewDidDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.contentInset.bottom = dateButton.frame.height + 40
    }
    
    func updateTitle() {
        title = viewModel.title
    }
    
    func updateTodayButton() {
        todayButton.isHidden = viewModel.todayButtonShouldHide
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        switch viewModel.viewKey {
        case .orders:
            guard let ordersViewController = storyboard?.instantiateViewController(withIdentifier: OrdersViewController.storyboardID) as? OrdersViewController else { return }
            ordersViewController.viewModel.viewKey = .foods
            ordersViewController.viewModel.orderFoods = viewModel.foods(for: indexPath)
            ordersViewController.viewModel.title = viewModel.orderTitle(for: indexPath)
            navigationController?.pushViewController(ordersViewController, animated: true)
        case .foods:
            performSegue(withIdentifier: SegueIdentifier.showFood.rawValue, sender: nil)
        }
    }
    
    func playAlertSound() {
        alertSound?.play(numberOfLoops: Constants.alertNumberOfLoops - 1) {
            guard $0 else { return }
            self.speakMessage()
        }
    }
    
    func speakMessage() {
        let message = Constants.alertMessage
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)
    }
    
    func setNothingViewConstraints() {
        nothingViewConstraints.forEach { $0.isActive = true }
    }
    
    func unsetNothingViewConstraints() {
        nothingViewConstraints.forEach { $0.isActive = false }
    }
    
    func setDatePickerViewConstraints() {
        datePickerViewConstraints.forEach { $0.isActive = true }
    }
    
    func unsetDatePickerViewConstraints() {
        datePickerViewConstraints.forEach { $0.isActive = false }
    }
    
    func setupAndShowNothingView() {
        nothingLabel.text = viewModel.nothingLabelText
        view.insertSubview(nothingView, belowSubview: dateButton)
        setNothingViewConstraints()
    }
    
    func hideNothingView() {
        unsetNothingViewConstraints()
        nothingView.removeFromSuperview()
    }
    
    func setupAndShowDatePickerView() {
        tapGestureRecognizer.isEnabled = true
        updateTodayButton()
        datePicker.date = viewModel.datePickerDate
        datePicker.minimumDate = viewModel.datePickerMinDate
        datePicker.maximumDate = viewModel.datePickerMaxDate
        datePickerView.effect = nil
        datePickerView.contentView.alpha = 0
        view.addSubview(datePickerView)
        setDatePickerViewConstraints()
        UIView.animate(withDuration: 0.25) {
            self.datePickerView.effect = self.datePickerViewEffect
            self.datePickerView.contentView.alpha = 1
        }
    }
    
    func hideDatePickerView() {
        UIView.animate(withDuration: 0.25, animations: {
            self.datePickerView.effect = nil
            self.datePickerView.contentView.alpha = 0
        }) {
            guard $0 else { return }
            self.unsetDatePickerViewConstraints()
            self.datePickerView.removeFromSuperview()
            self.tapGestureRecognizer.isEnabled = false
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifierString = segue.identifier,
            let identifier = SegueIdentifier(rawValue: identifierString) else { return }
        switch identifier {
        case .showFood:
            guard let orderViewController = (segue.destination as? UINavigationController)?.topViewController as? FoodViewController,
                let indexPath = tableView.indexPathForSelectedRow,
                let food = viewModel.food(for: indexPath) else { return }
            orderViewController.food = food
        }
    }
    
    // MARK: - IBActions
    @IBAction func didTapView(_ sender: UITapGestureRecognizer) {
        if datePickerView.superview != nil {
            hideDatePickerView()
        }
    }
    
    @IBAction func didTapDate(_ sender: UIButton) {
        setupAndShowDatePickerView()
    }
    
    @IBAction func didChangeDatePickerValue(_ sender: UIDatePicker) {
        UserDataStore.shared.observingDate = viewModel.isDateCurrent(sender.date) ? .current : .another(sender.date)
        updateTitle()
        updateTodayButton()
    }
    
    @IBAction func didTapToday(_ sender: UIButton) {
        datePicker.setDate(Date(), animated: true)
        didChangeDatePickerValue(datePicker)
    }
}

extension OrdersViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(inSection: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellViewModel = viewModel.cellViewModel(for: indexPath) else { fatalError() }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.identifier, for: indexPath)
        cellViewModel.commands[.configuration]?.perform(cell: cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.title(forSection: section)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cellViewModel = viewModel.cellViewModel(for: indexPath) else { fatalError() }
        return cellViewModel.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cellViewModel = viewModel.cellViewModel(for: indexPath),
            let cell = tableView.cellForRow(at: indexPath) else { fatalError() }
        cellViewModel.commands[.selection]?.perform(cell: cell)
        didSelectRow(at: indexPath)
    }
}

extension OrdersViewController: OrdersViewModelDelegate {
    func updateUI() {
        tableView.reloadData()
        if viewModel.isOrdersEmpty {
            setupAndShowNothingView()
        } else { hideNothingView() }
    }
    
    func didGetNewOrder() {
        playAlertSound()
    }
}
