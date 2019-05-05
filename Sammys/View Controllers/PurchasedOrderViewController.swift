//
//  PurchasedOrderViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 5/2/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class PurchasedOrderViewController: UIViewController {
    let viewModel = PurchasedOrderViewModel()
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    private let tableViewDataSource = UITableViewSectionModelsDataSource()
    private let tableViewDelegate = UITableViewSectionModelsDelegate()
    
    private lazy var doneBarButtonItemTarget = Target(action: doneBarButtonItemAction)
    
    private struct Constants {
        static let tintColor = #colorLiteral(red: 0.3294117647, green: 0.1921568627, blue: 0.09411764706, alpha: 1)
        
        static let progressTableViewCellViewModelProgressIsPendingColor = #colorLiteral(red: 1, green: 0.4588235294, blue: 0.2196078431, alpha: 1)
        static let progressTableViewCellViewModelProgressIsPreparingColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        static let progressTableViewCellViewModelProgressIsCompletedColor = #colorLiteral(red: 0.3254901961, green: 0.7607843137, blue: 0.168627451, alpha: 1)
        
        static let progressTableViewCellViewModelProgressIsPendingImage = #imageLiteral(resourceName: "Progress.Dots")
        static let progressTableViewCellViewModelProgressIsPreparingImage = #imageLiteral(resourceName: "Progress.Hat")
        static let progressTableViewCellViewModelProgressIsCompletedImage = #imageLiteral(resourceName: "Progress.Bag")
        
        static let progressTableViewCellTitleLabelText = "ORDER STATUS"
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
        self.navigationController?.navigationBar.tintColor = Constants.tintColor
        self.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .done, target: doneBarButtonItemTarget)
    }
    
    private func configureTableView() {
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
        tableView.register(ProgressTableViewCell.self, forCellReuseIdentifier: PurchasedOrderViewModel.CellIdentifier.progressTableViewCell.rawValue)
    }
    
    private func configureViewModel() {
        viewModel.progressTableViewCellViewModelActions = [
            .configuration: progressTableViewCellConfigurationAction
        ]
        
        viewModel.title.bindAndRun { self.title = $0 }
        
        viewModel.tableViewSectionModels.bindAndRun { value in
            self.tableViewDataSource.sectionModels = value
            self.tableViewDelegate.sectionModels = value
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Factory Methods
    private func makeColor(color: PurchasedOrderViewModel.Color) -> UIColor {
        switch color {
        case .progressTableViewCellViewModelProgressIsPendingColor:
            return Constants.progressTableViewCellViewModelProgressIsPendingColor
        case .progressTableViewCellViewModelProgressIsPreparingColor:
            return Constants.progressTableViewCellViewModelProgressIsPreparingColor
        case .progressTableViewCellViewModelProgressIsCompletedColor:
            return Constants.progressTableViewCellViewModelProgressIsCompletedColor
        }
    }
    
    private func makeImage(image: PurchasedOrderViewModel.Image) -> UIImage {
        switch image {
        case .progressTableViewCellViewModelProgressIsPendingImage:
            return Constants.progressTableViewCellViewModelProgressIsPendingImage
        case .progressTableViewCellViewModelProgressIsPreparingImage:
            return Constants.progressTableViewCellViewModelProgressIsPreparingImage
        case .progressTableViewCellViewModelProgressIsCompletedImage:
            return Constants.progressTableViewCellViewModelProgressIsCompletedImage
        }
    }
    
    // MARK: - Target Actions
    private func doneBarButtonItemAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Cell Actions
    private func progressTableViewCellConfigurationAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? PurchasedOrderViewModel.ProgressTableViewCellViewModel,
            let cell = data.cell as? ProgressTableViewCell else { return }
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        cell.circularImageView.backgroundColor = makeColor(color: cellViewModel.configurationData.color)
        cell.circularImageView.tintColor = .white
        cell.circularImageView.image = makeImage(image: cellViewModel.configurationData.image)
        
        cell.titleLabel.text = Constants.progressTableViewCellTitleLabelText
        cell.progressLabel.text = cellViewModel.configurationData.progressText
    }
}
