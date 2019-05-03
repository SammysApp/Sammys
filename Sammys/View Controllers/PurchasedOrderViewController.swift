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
    
    private struct Constants {
        static let progressIsPendingColor = #colorLiteral(red: 1, green: 0.4588235294, blue: 0.2196078431, alpha: 1)
        static let progressIsPreparingColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        static let progressIsCompletedColor = #colorLiteral(red: 0.3254901961, green: 0.7607843137, blue: 0.168627451, alpha: 1)
        
        static let progressIsPendingImage = #imageLiteral(resourceName: "Progress.Dots")
        static let progressIsPreparingImage = #imageLiteral(resourceName: "Progress.Hat")
        static let progressIsCompletedImage = #imageLiteral(resourceName: "Progress.Bag")
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        setUpView()
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
    
    private func configureTableView() {
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
        tableView.register(OrderProgressTableViewCell.self, forCellReuseIdentifier: PurchasedOrderViewModel.CellIdentifier.orderProgressTableViewCell.rawValue)
    }
    
    private func configureViewModel() {
        viewModel.progressTableViewCellViewModelActions = [
            .configuration: progressTableViewCellConfigurationAction
        ]
        
        viewModel.tableViewSectionModels.bindAndRun { value in
            self.tableViewDataSource.sectionModels = value
            self.tableViewDelegate.sectionModels = value
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Factory Methods
    private func makeColor(color: PurchasedOrderViewModel.Color) -> UIColor {
        switch color {
        case .progressIsPendingColor: return Constants.progressIsPendingColor
        case .progressIsPreparingColor: return Constants.progressIsPreparingColor
        case .progressIsCompletedColor: return Constants.progressIsCompletedColor
        }
    }
    
    private func makeImage(image: PurchasedOrderViewModel.Image) -> UIImage {
        switch image {
        case .progressIsPendingImage: return Constants.progressIsPendingImage
        case .progressIsPreparingImage: return Constants.progressIsPreparingImage
        case .progressIsCompletedImage: return Constants.progressIsCompletedImage
        }
    }
    
    // MARK: - Cell Actions
    private func progressTableViewCellConfigurationAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? PurchasedOrderViewModel.ProgressTableViewCellViewModel,
            let cell = data.cell as? OrderProgressTableViewCell else { return }
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        cell.circularImageView.backgroundColor = makeColor(color: cellViewModel.configurationData.color)
        cell.circularImageView.tintColor = .white
        cell.circularImageView.image = makeImage(image: cellViewModel.configurationData.image)
        cell.progressLabel.text = cellViewModel.configurationData.progressText
    }
}
