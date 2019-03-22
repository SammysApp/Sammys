//
//  HomeViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/21/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit
import TinyConstraints

class HomeViewController: UIViewController {
    let viewModel = HomeViewModel()
    
    let tableView = UITableView()
    
    private let tableViewDataSource = UITableViewSectionModelsDataSource()
    private let tableViewDelegate = UITableViewSectionModelsDelegate()
    
    private lazy var userBarButtonItemTarget = Target(action: userBarButtonItemTargetAction)
    
    enum CellIdentifier: String {
        case imageTableViewCell
    }
    
    private struct Constants {
        static let categoryImageTableViewCellTextLabelFontSize: CGFloat = 28
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureNavigation()
        configureViewModel()
        setUpView()
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
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.3294117647, green: 0.1921568627, blue: 0.09411764706, alpha: 1)
        let titleImage = #imageLiteral(resourceName: "NavBar.Title").withRenderingMode(.alwaysTemplate)
        let titleImageView = UIImageView(image: titleImage)
        titleImageView.tintColor = #colorLiteral(red: 0.1058823529, green: 0.1058823529, blue: 0.1098039216, alpha: 1)
        self.navigationItem.titleView = titleImageView
        self.navigationItem.rightBarButtonItem = .init(image: #imageLiteral(resourceName: "NavBar.User"), style: .plain, target: userBarButtonItemTarget)
    }
    
    private func configureTableView() {
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
        tableView.register(ImageTableViewCell.self, forCellReuseIdentifier: CellIdentifier.imageTableViewCell.rawValue)
    }
    
    private func configureViewModel() {
        viewModel.categoryImageTableViewCellViewModelActions = [
            .configuration: categoryImageTableViewCellConfigurationAction,
            .selection: categoryImageTableViewCellSelectionAction
        ]
        viewModel.tableViewSectionModels.bind { value in
            self.tableViewDataSource.sectionModels = value
            self.tableViewDelegate.sectionModels = value
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Factory Methods
    private func makeCategoryViewController(parentCategoryID: Category.ID? = nil, title: String? = nil) -> CategoryViewController {
        let categoryViewController = CategoryViewController()
        categoryViewController.title = title
        categoryViewController.viewModel.parentCategoryID = parentCategoryID
        return categoryViewController
    }
    
    // MARK: - Target Actions
    private func userBarButtonItemTargetAction() {
        self.present(UINavigationController(rootViewController: UserAuthPageViewController()), animated: true, completion: nil)
    }
    
    // MARK: - Cell Actions
    private func categoryImageTableViewCellConfigurationAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? HomeViewModel.CategoryImageTableViewCellViewModel,
            let cell = data.cell as? ImageTableViewCell else { return }
        cell.textLabel.text = cellViewModel.configurationData.text
        cell.textLabel.font = .systemFont(ofSize: Constants.categoryImageTableViewCellTextLabelFontSize, weight: .medium)
        cell.imageView.clipsToBounds = true
        cell.imageView.contentMode = .scaleAspectFill
        cellViewModel.configurationData.imageData.bindAndRun { data in
            guard let data = data else { return }
            cell.imageView.image = UIImage(data: data)
        }
        cell.prepareForReuseHandler = { cellViewModel.configurationData.imageData.unbind() }
    }
    
    private func categoryImageTableViewCellSelectionAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? HomeViewModel.CategoryImageTableViewCellViewModel else { return }
        navigationController?.pushViewController(
            makeCategoryViewController(parentCategoryID: cellViewModel.selectionData.id, title: cellViewModel.selectionData.title),
            animated: true
        )
    }
}
