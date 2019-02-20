//
//  TableViewCellCommand.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/29/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol TableViewCellCommand {
	func perform(cell: UITableViewCell?)
}
