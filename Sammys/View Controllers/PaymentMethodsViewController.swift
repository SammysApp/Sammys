//
//  PaymentMethodsViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/14/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit
import SquareInAppPaymentsSDK

class PaymentMethodsViewController: UIViewController {
    let viewModel = PaymentMethodsViewModel()
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    private let tableViewDataSource = UITableViewSectionModelsDataSource()
    private let tableViewDelegate = UITableViewSectionModelsDelegate()
    
    private lazy var addCardBarButtonItemTarget = Target(action: addCardBarButtonItemAction)
    
    private struct Constants {
        static let addCardBarButtonItemTitle = "Add Card"
        
        static let cardEntryViewControllerSaveButtonTitle = "Add"
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        setUpView()
        configureNavigation()
        configureViewModel()
        
        viewModel.beginDownloads()
    }
    
    // MARK: - Setup Methods
    private func setUpView() {
        addSubviews()
    }
    
    private func addSubviews() {
        [tableView].forEach { self.view.addSubview($0) }
        tableView.edgesToSuperview()
    }
    
    private func configureNavigation() {
        self.navigationItem.rightBarButtonItem = .init(title: Constants.addCardBarButtonItemTitle, style: .plain, target: addCardBarButtonItemTarget)
    }
    
    private func configureTableView() {
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: PaymentMethodsViewModel.CellIdentifier.tableViewCell.rawValue)
    }
    
    private func configureViewModel() {
        viewModel.paymentMethodTableViewCellViewModelActions = [
            .configuration: paymentMethodTableViewCellConfigurationAction,
            .selection: paymentMethodTableViewCellSelectionAction
        ]
        
        viewModel.tableViewSectionModels.bindAndRun { value in
            self.tableViewDataSource.sectionModels = value
            self.tableViewDelegate.sectionModels = value
            self.tableView.reloadData()
        }
        
        viewModel.errorHandler = { value in
            switch value {
            default: print(value.localizedDescription)
            }
        }
    }
    
    // MARK: - Factory Methods
    private func makeCardEntryViewController() -> SQIPCardEntryViewController {
        let theme = SQIPTheme()
        theme.saveButtonTitle = Constants.cardEntryViewControllerSaveButtonTitle
        let cardEntryViewController = SQIPCardEntryViewController(theme: theme)
        cardEntryViewController.collectPostalCode = true
        cardEntryViewController.delegate = self
        return cardEntryViewController
    }
    
    // MARK: - Target Actions
    private func addCardBarButtonItemAction() {
        self.present(UINavigationController(rootViewController: makeCardEntryViewController()), animated: true, completion: nil)
    }
    
    // MARK: - Cell Actions
    private func paymentMethodTableViewCellConfigurationAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? PaymentMethodsViewModel.PaymentMethodTableViewCellViewModel,
            let cell = data.cell else { return }
        
        cell.textLabel?.text = cellViewModel.configurationData.text
        cell.accessoryType = cellViewModel.configurationData.isSelected ? .checkmark : .none
    }
    
    private func paymentMethodTableViewCellSelectionAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? PaymentMethodsViewModel.PaymentMethodTableViewCellViewModel else { return }
        
        viewModel.selectedPaymentMethod = cellViewModel.selectionData.method
    }
}

extension PaymentMethodsViewController: SQIPCardEntryViewControllerDelegate {
    func cardEntryViewController(_ cardEntryViewController: SQIPCardEntryViewController, didObtain cardDetails: SQIPCardDetails, completionHandler: @escaping (Error?) -> Void) {
        guard let postalCode = cardDetails.card.postalCode else { preconditionFailure() }
        viewModel.beginCreateCardDownload(cardNonce: cardDetails.nonce, postalCode: postalCode) { result in
            switch result {
            case .fulfilled: completionHandler(nil)
            case .rejected(let error): completionHandler(error)
            }
        }
    }
    
    func cardEntryViewController(_ cardEntryViewController: SQIPCardEntryViewController, didCompleteWith status: SQIPCardEntryCompletionStatus) {
        dismiss(animated: true, completion: nil)
    }
}
