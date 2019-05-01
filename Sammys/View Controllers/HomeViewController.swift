//
//  HomeViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/21/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    let viewModel = HomeViewModel()
    
    let tableView = UITableView()
    
    let loadingView = BlurLoadingView()
    
    private let tableViewDataSource = UITableViewSectionModelsDataSource()
    private let tableViewDelegate = UITableViewSectionModelsDelegate()
    
    private lazy var userBarButtonItemTarget = Target(action: userBarButtonItemAction)
    
    private struct Constants {
        static let navigationBarTintColor = #colorLiteral(red: 0.3294117647, green: 0.1921568627, blue: 0.09411764706, alpha: 1)
        
        static let navigationItemTitleImage = #imageLiteral(resourceName: "NavBar.Title")
        static let navigationItemTitleViewTintColor = #colorLiteral(red: 0.1058823529, green: 0.1058823529, blue: 0.1098039216, alpha: 1)
        static let navigationItemRightBarButtonItemImage = #imageLiteral(resourceName: "NavBar.User")
        
        static let loadingViewHeight = CGFloat(100)
        static let loadingViewWidth = CGFloat(100)
        
        static let tableViewRowHeight = CGFloat(200)
        
        static let categoryImageTableViewCellTextLabelFontSize = CGFloat(28)
        static let categoryImageTableViewCellTextLabelFontWeight = UIFont.Weight.medium
        static let categoryImageTableViewCellTextLabelShadowOpacity = Float(0.15)
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureLoadingView()
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
        [tableView, loadingView]
            .forEach { self.view.addSubview($0) }
        tableView.edgesToSuperview()
        
        loadingView.centerInSuperview()
        loadingView.height(Constants.loadingViewHeight)
        loadingView.width(Constants.loadingViewWidth)
    }
    
    private func configureNavigation() {
        self.navigationController?.navigationBar.tintColor = Constants.navigationBarTintColor
        let titleImage = Constants.navigationItemTitleImage
        let titleImageView = UIImageView(image: titleImage)
        self.navigationItem.titleView = titleImageView
        self.navigationItem.titleView?.tintColor = Constants.navigationItemTitleViewTintColor
        self.navigationItem.rightBarButtonItem = .init(image: Constants.navigationItemRightBarButtonItemImage, style: .plain, target: userBarButtonItemTarget)
    }
    
    private func configureTableView() {
        tableView.rowHeight = Constants.tableViewRowHeight
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
        tableView.register(ImageTableViewCell.self, forCellReuseIdentifier: HomeViewModel.CellIdentifier.imageTableViewCell.rawValue)
    }
    
    private func configureLoadingView() {
        loadingView.image = #imageLiteral(resourceName: "Loading.Bagel")
    }
    
    private func configureViewModel() {
        viewModel.categoryImageTableViewCellViewModelActions = [
            .configuration: categoryImageTableViewCellConfigurationAction,
            .selection: categoryImageTableViewCellSelectionAction
        ]
        
        viewModel.tableViewSectionModels.bindAndRun { value in
            self.tableViewDataSource.sectionModels = value
            self.tableViewDelegate.sectionModels = value
            self.tableView.reloadData()
        }
        
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
    private func makeCategoriesViewController(parentCategoryID: Category.ID? = nil, title: String? = nil) -> CategoriesViewController {
        let categoriesViewController = CategoriesViewController()
        categoriesViewController.title = title
        categoriesViewController.viewModel.parentCategoryID = parentCategoryID
        return categoriesViewController
    }
    
    // MARK: - Target Actions
    private func userBarButtonItemAction() {
        let userViewController = UserViewController()
        self.present(UINavigationController(rootViewController: userViewController), animated: true, completion: nil)
    }
    
    // MARK: - Cell Actions
    private func categoryImageTableViewCellConfigurationAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? HomeViewModel.CategoryImageTableViewCellViewModel,
            let cell = data.cell as? ImageTableViewCell else { return }
        
        cell.textLabel.font = .systemFont(ofSize: Constants.categoryImageTableViewCellTextLabelFontSize, weight: Constants.categoryImageTableViewCellTextLabelFontWeight)
        cell.textLabel.text = cellViewModel.configurationData.text
        cell.textLabel.addShadow(.init(opacity: Constants.categoryImageTableViewCellTextLabelShadowOpacity))
        
        cell.imageView.clipsToBounds = true
        cell.imageView.contentMode = .scaleAspectFill
        cellViewModel.configurationData.imageData.bindAndRun { data in
            guard let data = data else { return }
            cell.imageView.image = UIImage(data: data)
        }
        
        // Unbind the image data from the reused cell's image to
        // avoid the wrong image being set.
        cell.prepareForReuseHandler = { cellViewModel.configurationData.imageData.unbindAll() }
    }
    
    private func categoryImageTableViewCellSelectionAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? HomeViewModel.CategoryImageTableViewCellViewModel else { return }
        
        navigationController?.pushViewController(
            makeCategoriesViewController(parentCategoryID: cellViewModel.selectionData.id, title: cellViewModel.selectionData.title),
            animated: true
        )
    }
}
