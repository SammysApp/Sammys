//
//  ItemsViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/25/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class ItemsViewController: UIViewController {
    let viewModel = ItemsViewModel()
    
    let tableView = UITableView()
    
    let modifiersViewController = ModifiersViewController()
	lazy var modifiersNavigationViewController = UINavigationController(rootViewController: modifiersViewController)
    
    private(set) lazy var longPressGestureRecognizer = UILongPressGestureRecognizer(target: longPressGestureRecognizerTarget)
    
    private let tableViewDataSource = UITableViewSectionModelsDataSource()
    private let tableViewDelegate = UITableViewSectionModelsDelegate()
    
    private lazy var longPressGestureRecognizerTarget = Target(action: longPressGestureRecognizerAction)
    
    private struct Constants {
        static let itemTableViewCellTintColor = #colorLiteral(red: 0.2509803922, green: 0.2, blue: 0.1529411765, alpha: 1)
        static let itemTableViewCellTextLabelFontSize = CGFloat(18)
        
        static let longPressGestureRecognizerMinimumPressDuration = Double(1)
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureModifiersViewController()
        configureLongPressGestureRecognizer()
        setUpView()
        configureViewModel()
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
        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: ItemsViewModel.CellIdentifier.subtitleTableViewCell.rawValue)
        tableView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    private func configureModifiersViewController() {
        modifiersViewController.viewModel.addModifierHandler = viewModel.addModifierHandler
        modifiersViewController.viewModel.removeModifierHandler = viewModel.removeModifierHandler
    }
    
    private func configureLongPressGestureRecognizer() {
        longPressGestureRecognizer.minimumPressDuration = Constants.longPressGestureRecognizerMinimumPressDuration
    }
    
    private func configureViewModel() {
        viewModel.itemTableViewCellViewModelActions = [
            .configuration: itemTableViewCellConfigurationAction,
            .selection: itemTableViewCellSelectionAction
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
    
    // MARK: - Target Actions
    private func longPressGestureRecognizerAction() {
        let longPressLocation = longPressGestureRecognizer.location(in: tableView)
        guard longPressGestureRecognizer.state == .began,
            let indexPath = tableView.indexPathForRow(at: longPressLocation),
            let cellViewModel = viewModel.tableViewSectionModels.value[indexPath.section].cellViewModels[indexPath.row] as? ItemsViewModel.ItemTableViewCellViewModel,
            cellViewModel.selectionData.isModifiable else { return }
		
		modifiersViewController.title = cellViewModel.selectionData.title
        modifiersViewController.viewModel.itemID = cellViewModel.selectionData.itemID
        modifiersViewController.viewModel.beginDownloads()
        
        self.present(modifiersNavigationViewController, animated: true, completion: nil)
    }
    
    // MARK: - Cell Actions
    private func itemTableViewCellConfigurationAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? ItemsViewModel.ItemTableViewCellViewModel,
            let cell = data.cell as? SubtitleTableViewCell else { return }
        
        cell.tintColor = Constants.itemTableViewCellTintColor
        cell.textLabel?.font = .systemFont(ofSize: Constants.itemTableViewCellTextLabelFontSize)
        cell.textLabel?.text = cellViewModel.configurationData.text
        cell.detailTextLabel?.text = cellViewModel.configurationData.detailText
        cell.accessoryType = cellViewModel.configurationData.isSelected ? .checkmark : .none
    }
    
    private func itemTableViewCellSelectionAction(data: UITableViewCellActionHandlerData) {
        guard let cellViewModel = data.cellViewModel as? ItemsViewModel.ItemTableViewCellViewModel,
            let id = cellViewModel.selectionData.categoryItemID else { return }
        
        if cellViewModel.selectionData.isModifiersRequired {
			modifiersViewController.title = cellViewModel.selectionData.title
            modifiersViewController.viewModel.itemID = cellViewModel.selectionData.itemID
            modifiersViewController.viewModel.beginDownloads()
            self.present(modifiersNavigationViewController, animated: true, completion: nil)
        } else {
            if cellViewModel.selectionData.isSelected { viewModel.remove(id) }
            else { viewModel.add(id) }
        }
    }
}
