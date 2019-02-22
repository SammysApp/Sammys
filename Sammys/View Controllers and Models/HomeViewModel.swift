//
//  HomeViewModel.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/21/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

enum HomeCellIdentifier: String {
    case imageCell
}

struct HomeViewModel {
    var tableViewSections: [TableViewSection] {
        return [
            TableViewSection(cellViewModels: [
                makeImageTableViewCellViewModel(configurationData: .init(text: "Hello"))
            ])
        ]
    }
    
    private func makeImageTableViewCellViewModel(configurationData: HomeViewController.ImageTableViewCellConfigurationData) -> BasicTableViewCellViewModel {
        return BasicTableViewCellViewModel(identifier: HomeCellIdentifier.imageCell.rawValue, height: 100, commands: [
            .configuration: HomeViewController.ImageTableViewCellConfiguration(data: configurationData)
        ])
    }
}
