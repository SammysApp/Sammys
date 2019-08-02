//
//  CheckoutViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/31/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit
import PassKit
import TinyConstraints

class CheckoutViewController: UIViewController {
    let viewModel = CheckoutViewModel()
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    let payButtonsStackView = UIStackView()
    let payButton = RoundedButton()
    let applePayButton = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
    
    let loadingView = BlurLoadingView()
    
    private(set) lazy var datePickerViewController = DatePickerViewController()
    
    private(set) lazy var tapGestureRecognizer = UITapGestureRecognizer(target: tapGestureRecognizerTarget)
    
    private let tableViewDataSource = UITableViewSectionModelsDataSource()
    private let tableViewDelegate = UITableViewSectionModelsDelegate()
    
    private lazy var payButtonTouchUpInsideTarget = Target(action: payButtonTouchUpInsideAction)
    private lazy var applePayButtonTouchUpInsideTarget = Target(action: applePayButtonTouchUpInsideAction)
    
    private lazy var tapGestureRecognizerTarget = Target(action: tapGestureRecognizerAction)
    
    var didCreatePurchasedOrderHandler: (PurchasedOrder.ID) -> Void = { _ in }
    
    private struct Constants {
        static let title = "Checkout"
        
        static let loadingViewHeight = CGFloat(100)
        static let loadingViewWidth = CGFloat(100)
        
        static let tableViewEstimatedRowHeight = CGFloat(60)
        
        static let addOfferAlertControllerTitle = "Add Discount Code"
        static let addOfferAlertControllerMessage = "Please enter the discount code below..."
        static let addOfferAlertControllerTextFieldPlaceholder = "Discount Code"
        static let addOfferAlertControllerDoneActionTitle = "Done"
        static let addOfferAlertControllerCancelActionTitle = "Cancel"
        static let addOfferAlertControllerTintColor = #colorLiteral(red: 0.3294117647, green: 0.1921568627, blue: 0.09411764706, alpha: 1)
        
        static let paymentMethodTableViewCellTextLabelText = "Payment Method"
        
        static let pickupDateTableViewCellTextLabelText = "Pickup"
        
        static let noteTableViewCellMinimumHeight = CGFloat(60)
        static let noteTableViewCellPlaceholderLabelTextColor = UIColor.lightGray
        static let noteTableViewCellTextViewTintColor = #colorLiteral(red: 0.3294117647, green: 0.1921568627, blue: 0.09411764706, alpha: 1)
        static let noteTableViewCellTextViewLeadingOffset = CGFloat(15)
        
        static let addOfferButtonTableViewCellTextLabelFontWeight = UIFont.Weight.semibold
        static let addOfferButtonTableViewCellTextLabelColor = #colorLiteral(red: 0.3294117647, green: 0.1921568627, blue: 0.09411764706, alpha: 1)
        
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
        configureLoadingView()
        configureDatePickerViewController()
        configureTapGestureRecognizer()
        setUpView()
        configureViewModel()
        
        viewModel.beginDownloads()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.deselectSelectedRow(animated: animated)
    }
    
    // MARK: - Setup Methods
    private func setUp() {
        self.title = Constants.title
    }
    
    private func setUpView() {
        addSubviews()
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func addSubviews() {
        [tableView, payButtonsStackView, loadingView]
            .forEach { self.view.addSubview($0) }
        tableView.edgesToSuperview()
        payButtonsStackView.height(Constants.payButtonsStackViewHeight)
        payButtonsStackView.edgesToSuperview(excluding: .top, insets: .init(top: 0, left: Constants.payButtonsStackViewHorizontalInset, bottom: 0, right: Constants.payButtonsStackViewHorizontalInset), usingSafeArea: true)
        
        loadingView.centerInSuperview()
        loadingView.height(Constants.loadingViewHeight)
        loadingView.width(Constants.loadingViewWidth)
    }
    
    private func configureTableView() {
        tableView.estimatedRowHeight = Constants.tableViewEstimatedRowHeight
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CheckoutViewModel.CellIdentifier.tableViewCell.rawValue)
        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: CheckoutViewModel.CellIdentifier.subtitleTableViewCell.rawValue)
        tableView.register(TextViewTableViewCell.self, forCellReuseIdentifier: CheckoutViewModel.CellIdentifier.textViewTableViewCell.rawValue)
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
    
    private func configureLoadingView() {
        loadingView.image = #imageLiteral(resourceName: "Loading.Bagel")
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
    
    private func configureTapGestureRecognizer() {
        tapGestureRecognizer.isEnabled = false
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
        
        viewModel.noteTableViewCellViewModelActions = [
            .configuration: noteTableViewCellConfigurationAction
        ]
        
        viewModel.addOfferButtonTableViewCellViewModelActions = [
            .configuration: addOfferButtonTableViewCellConfigurationAction,
            .selection: addOfferButtonTableViewCellSelectionAction
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
        
        viewModel.isLoading.bindAndRun { value in
            self.view.isUserInteractionEnabled = !value
            if value { self.loadingView.startAnimating() }
            else { self.loadingView.stopAnimating() }
        }
        
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
    
    private func makeAddOfferAlertController() -> UIAlertController {
        let alertController = UIAlertController(title: Constants.addOfferAlertControllerTitle, message: Constants.addOfferAlertControllerMessage, preferredStyle: .alert)
        alertController.view.tintColor = Constants.addOfferAlertControllerTintColor
        alertController.addTextField { textField in
            textField.placeholder = Constants.addOfferAlertControllerTextFieldPlaceholder
        }
        alertController.addActions([
            UIAlertAction(title: Constants.addOfferAlertControllerDoneActionTitle, style: .default) { _ in
                guard let code = alertController.textFields?.first?.text?.trimmingCharacters(in: .whitespaces) else { return }
                self.viewModel.beginAddOutstandingOrderOfferDownload(code: code)
            },
            UIAlertAction(title: Constants.addOfferAlertControllerCancelActionTitle, style: .cancel) { _ in self.dismiss(animated: true, completion: nil) }
        ])
        return alertController
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
    
    private func tapGestureRecognizerAction() {
        self.view.endEditing(true)
        tapGestureRecognizer.isEnabled = false
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
    
    private func noteTableViewCellConfigurationAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? CheckoutViewModel.NoteTableViewCellViewModel,
            let cell = data.cell as? TextViewTableViewCell else { return }
        
        cell.placeholderLabel.font = .systemFont(ofSize: cell.textLabel?.font.pointSize ?? 0)
        cell.placeholderLabel.textColor = Constants.noteTableViewCellPlaceholderLabelTextColor
        cell.placeholderLabel.text = cellViewModel.configurationData.placeholderText
        
        cell.textView.isScrollEnabled = false
        cell.textView.tintColor = Constants.noteTableViewCellTextViewTintColor
        cell.textView.font = .systemFont(ofSize: cell.textLabel?.font.pointSize ?? 0)
        cell.set(textViewText: cellViewModel.configurationData.text ?? String())
        cell.textViewLeadingOffset = Constants.noteTableViewCellTextViewLeadingOffset
        
        let heightView = UIView()
        cell.insertSubview(heightView, belowSubview: cell.textView)
        heightView.edgesToSuperview()
        heightView.height(Constants.noteTableViewCellMinimumHeight, relation: .equalOrGreater)
        
        cell.textViewDidBeginEditingHandler = { self.tapGestureRecognizer.isEnabled = true }
        
        cell.textViewTextDidChangeHandler = { text in
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            
            self.viewModel.beginUpdateOutstandingOrderDownload(note: text.isEmpty ? nil : text)
        }
    }
    
    private func addOfferButtonTableViewCellConfigurationAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? CheckoutViewModel.AddOfferButtonTableViewCellViewModel,
            let cell = data.cell else { return }
        
        cell.textLabel?.textColor = Constants.addOfferButtonTableViewCellTextLabelColor
        cell.textLabel?.font = .systemFont(ofSize: cell.textLabel?.font.pointSize ?? 0, weight: Constants.addOfferButtonTableViewCellTextLabelFontWeight)
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.text = cellViewModel.configurationData.title
    }
    
    private func addOfferButtonTableViewCellSelectionAction(data: UITableViewCellActionHandlerData) {
        self.present(makeAddOfferAlertController(), animated: true, completion: nil)
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
                controller.dismiss(animated: true) {
                    self.didCreatePurchasedOrderHandler(id)
                }
                completion(.init(status: .success, errors: nil))
            case .rejected(let error):
                completion(.init(status: .failure, errors: [error]))
            }
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        if controller.isBeingPresented {
            controller.dismiss(animated: true, completion: nil)
        }
    }
}
