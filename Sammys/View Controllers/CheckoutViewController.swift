//
//  CheckoutViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/31/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit
import SquareInAppPaymentsSDK

class CheckoutViewController: UIViewController {
    let viewModel = CheckoutViewModel()
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    let payButton = RoundedButton()
    
    private(set) lazy var datePickerViewController = DatePickerViewController()
    
    private let tableViewDataSource = UITableViewSectionModelsDataSource()
    private let tableViewDelegate = UITableViewSectionModelsDelegate()
    
    private lazy var payButtonTouchUpInsideTarget = Target(action: payButtonTouchUpInsideAction)
    
    private struct Constants {
        static let pickupDateTableViewCellTextLabelText = "Pickup"
        
        static let payButtonBackgroundColor = #colorLiteral(red: 0.3294117647, green: 0.1921568627, blue: 0.09411764706, alpha: 1)
        static let payButtonTitleLabelTextColor = UIColor.white
        static let payButtonTitleLabelText = "Pay"
        
        static let datePickerViewControllerMinuteInterval = 15
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configurePayButton()
        configureDatePickerViewController()
        setUpView()
        configureViewModel()
        
        viewModel.beginDownloads()
    }
    
    // MARK: - Setup Methods
    private func setUpView() {
        addSubviews()
    }
    
    private func addSubviews() {
        [tableView, payButton]
            .forEach { self.view.addSubview($0) }
        tableView.edgesToSuperview()
        payButton.edgesToSuperview(excluding: .top, usingSafeArea: true)
    }
    
    private func configureTableView() {
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: CheckoutViewModel.CellIdentifier.subtitleTableViewCell.rawValue)
    }
    
    private func configurePayButton() {
        payButton.backgroundColor = Constants.payButtonBackgroundColor
        payButton.titleLabel.textColor = Constants.payButtonTitleLabelTextColor
        payButton.titleLabel.text = Constants.payButtonTitleLabelText
        payButton.add(payButtonTouchUpInsideTarget, for: .touchUpInside)
    }
    
    private func configureDatePickerViewController() {
        datePickerViewController.viewModel.minuteInterval = Constants.datePickerViewControllerMinuteInterval
        
        datePickerViewController.didSelectDateHandler = { date in
            switch date {
            case .asap:
                self.viewModel.beginUpdateOutstandingOrderPreparedForDateDownload(date: nil)
            case .date(let date):
                self.viewModel.beginUpdateOutstandingOrderPreparedForDateDownload(date: date)
            }
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func configureViewModel() {
        viewModel.pickupDateTableViewCellViewModelActions = [
            .configuration: pickupDateTableViewCellConfigurationAction,
            .selection: pickupDateTableViewCellSelectionAction
        ]
        
        viewModel.tableViewSectionModels.bindAndRun { value in
            self.tableViewDataSource.sectionModels = value
            self.tableViewDelegate.sectionModels = value
            self.tableView.reloadData()
        }
        
        viewModel.pickupDate.bindAndRun { value in
            guard let date = value else { return }
            self.datePickerViewController.viewModel.selectedDate = .date(date)
        }
        
        viewModel.minimumPickupDate.bindAndRun { self.datePickerViewController.viewModel.minimumDate = $0 }
        viewModel.maximumPickupDate.bindAndRun { self.datePickerViewController.viewModel.maximumDate = $0 }
        
        viewModel.errorHandler = { value in
            switch value {
            default: print(value.localizedDescription)
            }
        }
    }
    
    // MARK: - Target Actions
    private func payButtonTouchUpInsideAction() {
        self.present(UINavigationController(rootViewController: makeCardEntryViewController()), animated: true, completion: nil)
    }
    
    // MARK: - Factory Methods
    private func makeCardEntryViewController() -> SQIPCardEntryViewController {
        let theme = SQIPTheme()
        let cardEntryViewController = SQIPCardEntryViewController(theme: theme)
        cardEntryViewController.delegate = self
        return cardEntryViewController
    }
    
    // MARK: - Cell Actions
    private func pickupDateTableViewCellConfigurationAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? CheckoutViewModel.PickupDateTableViewCellViewModel,
            let cell = data.cell as? SubtitleTableViewCell else { return }
        
        cell.textLabel?.text = Constants.pickupDateTableViewCellTextLabelText
        cell.detailTextLabel?.text = cellViewModel.configurationData.detailText
    }
    
    private func pickupDateTableViewCellSelectionAction(data: UITableViewCellActionHandlerData) {
        viewModel.beginStoreHoursDownload()
        self.navigationController?.pushViewController(datePickerViewController, animated: true)
    }
}

extension CheckoutViewController: SQIPCardEntryViewControllerDelegate {
    func cardEntryViewController(_ cardEntryViewController: SQIPCardEntryViewController, didObtain cardDetails: SQIPCardDetails, completionHandler: @escaping (Error?) -> Void) {
        viewModel.beginCreatePurchasedOrderDownload(cardNonce: cardDetails.nonce) { result in
            switch result {
            case .fulfilled(_): completionHandler(nil)
            case .rejected(let error): completionHandler(error)
            }
        }
    }
    
    func cardEntryViewController(_ cardEntryViewController: SQIPCardEntryViewController, didCompleteWith status: SQIPCardEntryCompletionStatus) {}
}
