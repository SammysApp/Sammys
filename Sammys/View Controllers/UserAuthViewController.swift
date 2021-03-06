//
//  UserAuthViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/19/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class UserAuthViewController: UIViewController {
    let viewModel = UserAuthViewModel()
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    let completeButton = RoundedButton()
    
    let loadingView = BlurLoadingView()
    
    private let tableViewDataSource = UITableViewSectionModelsDataSource()
    private let tableViewDelegate = UITableViewSectionModelsDelegate()
    
    private lazy var completeButtonTouchUpInsideTarget = Target(action: completeButtonTouchUpInsideAction)
    
    private struct Constants {
        static let loadingViewHeight = CGFloat(100)
        static let loadingViewWidth = CGFloat(100)
        
        static let textFieldTableViewCellTitleLabelWidth = CGFloat(120)
        static let textFieldTableViewCellTextFieldTintColor = #colorLiteral(red: 0.3294117647, green: 0.1921568627, blue: 0.09411764706, alpha: 1)
        
        static let tableViewTableFooterViewHeight = CGFloat(60)
        
        static let completeButtonBackgroundColor = #colorLiteral(red: 0.3333333333, green: 0.3019607843, blue: 0.2745098039, alpha: 1)
        static let completeButtonTitleLabelTextColor = UIColor.white
        static let completeButtonTitleLabelFontSize = CGFloat(20)
        static let completeButtonTitleLabelFontWeight = UIFont.Weight.medium
        static let completeButtonHorizontalInset = CGFloat(10)
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureCompleteButton()
        configureLoadingView()
        setUpView()
        configureViewModel()
    }
    
    // MARK: - Setup Methods
    private func setUpView() {
        addSubviews()
    }
    
    private func addSubviews() {
        [tableView, loadingView]
            .forEach { self.view.addSubview($0) }
        tableView.edgesToSuperview()
        
        loadingView.centerInSuperview()
        loadingView.height(Constants.loadingViewHeight)
        loadingView.width(Constants.loadingViewWidth)
    }
    
    private func configureTableView() {
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: UserAuthViewModel.CellIdentifier.textFieldTableViewCell.rawValue)
        tableView.tableFooterView = makeTableViewTableFooterView()
    }
    
    private func configureLoadingView() {
        loadingView.image = #imageLiteral(resourceName: "Loading.Bagel")
    }
    
    private func configureCompleteButton() {
        completeButton.backgroundColor = Constants.completeButtonBackgroundColor
        completeButton.titleLabel.textColor = Constants.completeButtonTitleLabelTextColor
        completeButton.titleLabel.font = .systemFont(ofSize: Constants.completeButtonTitleLabelFontSize, weight: Constants.completeButtonTitleLabelFontWeight)
        completeButton.add(completeButtonTouchUpInsideTarget, for: .touchUpInside)
    }
    
    private func configureViewModel() {
        viewModel.textFieldTableViewCellViewModelActions = [
            .configuration: textFieldTableViewCellConfigurationAction
        ]
        
        viewModel.tableViewSectionModels.bindAndRun { value in
            self.tableViewDataSource.sectionModels = value
            self.tableViewDelegate.sectionModels = value
            self.tableView.reloadData()
        }
        
        viewModel.completedButtonText.bindAndRun { self.completeButton.titleLabel.text = $0 }
        
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
    
    // MARK: - Factory Methods
    private func makeTableViewTableFooterView() -> UIView {
        let footerView = UIView(frame: .init(x: 0, y: 0, width: 0, height: Constants.tableViewTableFooterViewHeight))
        footerView.addSubview(completeButton)
        completeButton.edgesToSuperview(insets: .init(top: 0, left: Constants.completeButtonHorizontalInset, bottom: 0, right: Constants.completeButtonHorizontalInset))
        return footerView
    }
    
    // MARK: - Target Actions
    func completeButtonTouchUpInsideAction() {
        viewModel.beginCompleteDownload()
    }
    
    // MARK: - Cell Actions
    private func textFieldTableViewCellConfigurationAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? UserAuthViewModel.TextFieldTableViewCellViewModel,
            let cell = data.cell as? TextFieldTableViewCell else { return }
        
        cell.titleLabelWidth = Constants.textFieldTableViewCellTitleLabelWidth
        cell.titleLabel.text = cellViewModel.configurationData.title
        
        cell.textField.tintColor = Constants.textFieldTableViewCellTextFieldTintColor
        if cellViewModel.configurationData.isEmailTextEntry {
            cell.textField.keyboardType = .emailAddress
            cell.textField.autocapitalizationType = .none
        } else {
            cell.textField.keyboardType = .default
            cell.textField.autocapitalizationType = .words
        }
        cell.textField.isSecureTextEntry = cellViewModel.configurationData.isSecureTextEntry
        cell.textFieldTextUpdateHandler = cellViewModel.configurationData.textFieldTextDidUpdateHandler
    }
}
