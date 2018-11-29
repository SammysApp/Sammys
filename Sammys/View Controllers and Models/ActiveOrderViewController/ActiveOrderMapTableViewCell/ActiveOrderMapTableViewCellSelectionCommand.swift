//
//  ActiveOrderMapTableViewCellSelectionCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/18/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

struct ActiveOrderMapTableViewCellSelectionCommand: TableViewCellCommand {
    func perform(parameters: TableViewCellCommandParameters) {
		guard let activeOrderViewController = parameters.viewController as? ActiveOrderViewController else { return }
		do { try activeOrderViewController.presentNavigationAlert() } catch { print(error) }
	}
}
