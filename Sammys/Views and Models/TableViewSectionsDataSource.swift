//
//  TableViewSectionsDataSource.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/21/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol TableViewSectionsDataSource {
    func tableViewSections(for tableView: UITableView) -> [TableViewSection]
}

extension TableViewSectionsDataSource {
    func cellViewModel(for indexPath: IndexPath, in tableView: UITableView) -> TableViewCellViewModel {
        return tableViewSections(for: tableView)[indexPath.section]
            .cellViewModels[indexPath.row]
    }
}

class TableViewSectionsUITableViewDataSource: NSObject, UITableViewDataSource {
    let dataSource: TableViewSectionsDataSource
    
    init(dataSource: TableViewSectionsDataSource) {
        self.dataSource = dataSource
        super.init()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.tableViewSections(for: tableView).count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.tableViewSections(for: tableView)[section].cellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = dataSource.cellViewModel(for: indexPath, in: tableView)
        return tableView.dequeueReusableCell(withIdentifier: cellViewModel.identifier, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource.tableViewSections(for: tableView)[section].title
    }
}

class TableViewSectionsUITableViewDelegate: NSObject, UITableViewDelegate {
    let dataSource: TableViewSectionsDataSource
    
    init(dataSource: TableViewSectionsDataSource) {
        self.dataSource = dataSource
        super.init()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellViewModel = dataSource.cellViewModel(for: indexPath, in: tableView)
        cellViewModel.commands[.configuration]?.perform(cell: cell)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(dataSource.cellViewModel(for: indexPath, in: tableView).height)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let cellViewModel = dataSource.cellViewModel(for: indexPath, in: tableView)
        cellViewModel.commands[.selection]?.perform(cell: cell)
    }
}
