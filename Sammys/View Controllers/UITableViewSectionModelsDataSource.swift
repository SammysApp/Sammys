//
//  UITableViewSectionModelsDataSource.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/21/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class UITableViewSectionModelsDataSource: NSObject, UITableViewDataSource {
    var sectionModels: [UITableViewSectionModel]
    
    init(sectionModels: [UITableViewSectionModel] = []) {
        self.sectionModels = sectionModels
        super.init()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionModels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionModels[section].cellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: sectionModels.cellViewModel(for: indexPath).identifier, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionModels[section].title
    }
}
