//
//  UITableViewSectionModelsDelegate.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/22/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class UITableViewSectionModelsDelegate: NSObject, UITableViewDelegate {
    var sectionModels: [UITableViewSectionModel]
    
    init(sections: [UITableViewSectionModel] = []) {
        self.sectionModels = sections
        super.init()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        sectionModels.cellViewModel(for: indexPath).perform(.configuration, indexPath: indexPath, cell: cell)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch sectionModels.cellViewModel(for: indexPath).height {
        case .automatic: return UITableView.automaticDimension
        case .fixed(let height): return CGFloat(height)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sectionModels.cellViewModel(for: indexPath).perform(.selection, indexPath: indexPath)
    }
}
