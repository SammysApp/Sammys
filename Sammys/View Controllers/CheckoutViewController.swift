//
//  CheckoutViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/31/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit
import PassKit

class CheckoutViewController: UIViewController {
    let viewModel = CheckoutViewModel()
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    let payButtonsStackView = UIStackView()
    let payButton = RoundedButton()
    let applePayButton = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
    
    private(set) lazy var datePickerViewController = DatePickerViewController()
    
    private let tableViewDataSource = UITableViewSectionModelsDataSource()
    private let tableViewDelegate = UITableViewSectionModelsDelegate()
    
    private lazy var payButtonTouchUpInsideTarget = Target(action: payButtonTouchUpInsideAction)
    private lazy var applePayButtonTouchUpInsideTarget = Target(action: applePayButtonTouchUpInsideAction)
    
    var didCreatePurchasedOrderHandler: (PurchasedOrder.ID) -> Void = { _ in }
    
    private struct Constants {
        static let title = "Checkout"
        
        static let paymentMethodTableViewCellTextLabelText = "Payment Method"
        
        static let pickupDateTableViewCellTextLabelText = "Pickup"
        
        static let payButtonsStackViewHeight = CGFloat(60)
        static let payButtonsStackViewHorizontalInset = CGFloat(10)
        
        static let payButtonBackgroundColor = #colorLiteral(red: 0.2509803922, green: 0.2, blue: 0.1529411765, alpha: 1)
        static let payButtonTitleLabelFontSize = CGFloat(20)
        static let payButtonTitleLabelFontWeight = UIFont.Weight.medium
        static let payButtonTitleLabelTextColor = UIColor.white
        static let payButtonTitleLabelText = "Buy with Card"
        
        static let applePayButtonCornerRadiusMultiplier = CGFloat(0.2)
        
        static let datePickerViewControllerMinuteInterval = 15
        static let datePickerViewControllerTitle = "Pickup"
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
        configureTableView()
        configurePayButton()
        configureApplePayButton()
        configurePayButtonsStackView()
        configureDatePickerViewController()
        setUpView()
        configureViewModel()
        
        viewModel.beginDownloads()
    }
    
    // MARK: - Setup Methods
    private func setUp() {
        self.title = Constants.title
    }
    
    private func setUpView() {
        addSubviews()
    }
    
    private func addSubviews() {
        [tableView, payButtonsStackView]
            .forEach { self.view.addSubview($0) }
        tableView.edgesToSuperview()
        payButtonsStackView.height(Constants.payButtonsStackViewHeight)
        payButtonsStackView.edgesToSuperview(excluding: .top, insets: .init(top: 0, left: Constants.payButtonsStackViewHorizontalInset, bottom: 0, right: Constants.payButtonsStackViewHorizontalInset), usingSafeArea: true)
    }
    
    private func configureTableView() {
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: CheckoutViewModel.CellIdentifier.subtitleTableViewCell.rawValue)
        tableView.register(TotalTableViewCell.self, forCellReuseIdentifier: CheckoutViewModel.CellIdentifier.totalTableViewCell.rawValue)
    }
    
    private func configurePayButtonsStackView() {
        [payButton, applePayButton]
            .forEach { payButtonsStackView.addArrangedSubview($0) }
        payButtonsStackView.distribution = .fillEqually
    }
    
    private func configurePayButton() {
        payButton.backgroundColor = Constants.payButtonBackgroundColor
        payButton.titleLabel.font = .systemFont(ofSize: Constants.payButtonTitleLabelFontSize, weight: Constants.payButtonTitleLabelFontWeight)
        payButton.titleLabel.textColor = Constants.payButtonTitleLabelTextColor
        payButton.titleLabel.text = Constants.payButtonTitleLabelText
        payButton.add(payButtonTouchUpInsideTarget, for: .touchUpInside)
        payButton.isHidden = true
    }
    
    private func configureApplePayButton() {
        if #available(iOS 12.0, *) {
            applePayButton.cornerRadius = Constants.payButtonsStackViewHeight * Constants.applePayButtonCornerRadiusMultiplier
        }
        applePayButton.add(applePayButtonTouchUpInsideTarget, for: .touchUpInside)
        applePayButton.isHidden = true
    }
    
    private func configureDatePickerViewController() {
        datePickerViewController.title = Constants.datePickerViewControllerTitle
        datePickerViewController.viewModel.minuteInterval = Constants.datePickerViewControllerMinuteInterval
        
        datePickerViewController.didSelectDateHandler = { date in
            switch date {
            case .asap:
                self.viewModel.beginUpdateOutstandingOrderDownload(preparedForDate: nil)
            case .date(let date):
                self.viewModel.beginUpdateOutstandingOrderDownload(preparedForDate: date)
            }
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func configureViewModel() {
        viewModel.paymentMethodTableViewCellViewModelActions = [
            .configuration: paymentMethodTableViewCellConfigurationAction,
            .selection: paymentMethodTableViewCellSelectionAction
        ]
        
        viewModel.pickupDateTableViewCellViewModelActions = [
            .configuration: pickupDateTableViewCellConfigurationAction,
            .selection: pickupDateTableViewCellSelectionAction
        ]
        
        viewModel.totalTableViewCellViewModelActions = [
            .configuration: totalTableViewCellConfigurationAction
        ]
        
        viewModel.tableViewSectionModels.bindAndRun { value in
            self.tableViewDataSource.sectionModels = value
            self.tableViewDelegate.sectionModels = value
            self.tableView.reloadData()
        }
        
        viewModel.paymentMethod.bindAndRun { value in
            guard let method = value else { return }
            switch method {
            case .applePay: self.setUpShowApplePayButton()
            case .card: self.setUpShowPayButton()
            }
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
    
    private func setUpShowPayButton() {
        applePayButton.isHidden = true
        payButton.isHidden = false
    }
    
    private func setUpShowApplePayButton() {
        payButton.isHidden = true
        applePayButton.isHidden = false
    }
    
    // MARK: - Factory Methods
    private func makePaymentMethodsViewController() -> PaymentMethodsViewController {
        let paymentMethodsViewController = PaymentMethodsViewController()
        paymentMethodsViewController.viewModel.userID = viewModel.userID
        
        paymentMethodsViewController.viewModel.didSelectPaymentMethodHandler = { method in
            self.viewModel.paymentMethod.value = method
            self.navigationController?.popViewController(animated: true)
        }
        
        return paymentMethodsViewController
    }
    
    private func makePaymentAuthorizationViewController(paymentRequest: PKPaymentRequest) -> PKPaymentAuthorizationViewController? {
        let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
        paymentAuthorizationViewController?.delegate = self
        return paymentAuthorizationViewController
    }
    
    // MARK: - Target Actions
    private func payButtonTouchUpInsideAction() {
        guard let method = viewModel.paymentMethod.value,
            case .card(let id, _) = method else { return }
        viewModel.beginCreatePurchasedOrderDownload(customerCardID: id, successHandler: didCreatePurchasedOrderHandler)
    }
    
    private func applePayButtonTouchUpInsideAction() {
        viewModel.beginPaymentRequestDownload() { paymentRequest in
            if let paymentAuthorizationViewController = self.makePaymentAuthorizationViewController(paymentRequest: paymentRequest) {
                self.present(paymentAuthorizationViewController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Cell Actions
    private func paymentMethodTableViewCellConfigurationAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? CheckoutViewModel.PaymentMethodTableViewCellViewModel,
            let cell = data.cell as? SubtitleTableViewCell else { return }
        
        cell.textLabel?.text = Constants.paymentMethodTableViewCellTextLabelText
        cell.detailTextLabel?.text = cellViewModel.configurationData.detailText
    }
    
    private func paymentMethodTableViewCellSelectionAction(data: UITableViewCellActionHandlerData) {
        self.navigationController?.pushViewController(makePaymentMethodsViewController(), animated: true)
    }
    
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
    
    private func totalTableViewCellConfigurationAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? CheckoutViewModel.TotalTableViewCellViewModel,
            let cell = data.cell as? TotalTableViewCell else { return }
        
        cell.subtotalPriceLabel.text = cellViewModel.configurationData.subtotalText
        cell.taxPriceLabel.text = cellViewModel.configurationData.taxText
        cell.totalPriceLabel.text = cellViewModel.configurationData.totalText
    }
}

extension CheckoutViewController: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        viewModel.beginCreatePurchasedOrderDownload(payment: payment) { result in
            switch result {
            case .fulfilled(let id):
                completion(.init(status: .success, errors: nil))
                self.didCreatePurchasedOrderHandler(id)
            case .rejected(let error):
                completion(.init(status: .failure, errors: [error]))
            }
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
