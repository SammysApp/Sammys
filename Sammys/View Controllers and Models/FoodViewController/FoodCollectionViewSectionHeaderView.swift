//
//  FoodCollectionViewSectionHeaderView.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/18/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol FoodCollectionViewSectionHeaderViewDelegate {
	func foodCollectionViewSectionHeaderView(_ foodCollectionViewSectionHeaderView: FoodCollectionViewSectionHeaderView, didTapEdit editButton: UIButton)
}

class FoodCollectionViewSectionHeaderView: UICollectionReusableView {
	var delegate: FoodCollectionViewSectionHeaderViewDelegate?
	
	// MARK:- IBOutlets
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var editButton: UIButton!
	
	// MARK: - IBAction
	@IBAction func didTapEdit(_ sender: UIButton) { delegate?.foodCollectionViewSectionHeaderView(self, didTapEdit: sender) }
}

// MARK: - Nibable
extension FoodCollectionViewSectionHeaderView: Nibable {}
