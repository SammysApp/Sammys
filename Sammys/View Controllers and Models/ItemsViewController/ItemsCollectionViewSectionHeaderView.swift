//
//  ItemsCollectionViewSectionHeaderView.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/18/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol ItemsCollectionViewSectionHeaderViewDelegate {
	func itemsCollectionViewSectionHeaderView(_ itemsCollectionViewSectionHeaderView: ItemsCollectionViewSectionHeaderView, didTapEditButton button: UIButton)
}

class ItemsCollectionViewSectionHeaderView: UICollectionReusableView {
	var delegate: ItemsCollectionViewSectionHeaderViewDelegate?
	
	// MARK:- IBOutlets
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var editButton: UIButton!
	
	// MARK: - IBAction
	@IBAction func didTapEdit(_ sender: UIButton) { delegate?.itemsCollectionViewSectionHeaderView(self, didTapEditButton: sender) }
}

// MARK: - Nibable
extension ItemsCollectionViewSectionHeaderView: Nibable {}
