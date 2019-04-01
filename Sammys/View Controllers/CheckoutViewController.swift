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
    
    let tableView = UITableView()
    let payButton = RoundedButton()
    
    private let tableViewDataSource = UITableViewSectionModelsDataSource()
    private let tableViewDelegate = UITableViewSectionModelsDelegate()
    
    private lazy var payButtonTouchUpInsideTarget = Target(action: payButtonTouchUpInsideAction)
    
    private struct Constants {
        static let payButtonTitleLabelText = "Pay"
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configurePayButton()
        setUpView()
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
    }
    
    private func configurePayButton() {
        payButton.backgroundColor = #colorLiteral(red: 0.3294117647, green: 0.1921568627, blue: 0.09411764706, alpha: 1)
        payButton.titleLabel.textColor = .white
        payButton.titleLabel.text = Constants.payButtonTitleLabelText
        payButton.add(payButtonTouchUpInsideTarget, for: .touchUpInside)
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
}

extension CheckoutViewController: SQIPCardEntryViewControllerDelegate {
    func cardEntryViewController(_ cardEntryViewController: SQIPCardEntryViewController, didObtain cardDetails: SQIPCardDetails, completionHandler: @escaping (Error?) -> Void) {
        viewModel.beginCreatePurchasedOrderDownload(cardNonce: cardDetails.nonce) { result in
            switch result {
            case .fulfilled(_):
                completionHandler(nil)
            case .rejected(let error): completionHandler(error)
            }
        }
    }
    
    func cardEntryViewController(_ cardEntryViewController: SQIPCardEntryViewController, didCompleteWith status: SQIPCardEntryCompletionStatus) {
        
    }
}
