//
//  FoodHeaderView.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/18/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class FoodHeaderView: UICollectionReusableView {
    let titleLabel = UILabel()
    let editButton = UIButton(type: .system)
    private var leftConstraint: NSLayoutConstraint?
	private var rightConstraint: NSLayoutConstraint?
    
    var leftInset: CGFloat = Constants.defaultInset { didSet { updateViews() } }
	var rightInset: CGFloat = Constants.defaultInset { didSet { updateViews() } }
    var isEditButtonVisible = true { didSet { updateViews() } }
    
    private struct Constants {
		static let defaultInset: CGFloat = 15
		static let titleLabelFontSize: CGFloat = 24
		static let editButtonFontSize: CGFloat = 18
        static let edit = "Edit"
    }
    
	override init(frame: CGRect) { super.init(frame: frame); setupViews() }
	required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder); setupViews() }
    
    private func setupViews() {
        setupTitleLabel()
    }
	
	private func setupTitleLabel() {
		addSubview(titleLabel)
		titleLabel.font = UIFont.systemFont(ofSize: Constants.titleLabelFontSize, weight: .medium)
		titleLabel.textColor = #colorLiteral(red: 0.3333333333, green: 0.3019607843, blue: 0.2745098039, alpha: 1)
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		[titleLabel.topAnchor.constraint(equalTo: topAnchor),
		 titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)]
			.forEach { $0.isActive = true }
		leftConstraint = titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: leftInset)
		leftConstraint?.isActive = true
	}
	
	private func setupEditButton() {
		addSubview(editButton)
		editButton.titleLabel?.font = UIFont.systemFont(ofSize: Constants.editButtonFontSize, weight: .medium)
		editButton.setTitleColor(#colorLiteral(red: 0.3333333333, green: 0.3019607843, blue: 0.2745098039, alpha: 1), for: .normal)
		editButton.setTitle(Constants.edit, for: .normal)
		editButton.translatesAutoresizingMaskIntoConstraints = false
		editButton.leftAnchor.constraint(equalTo: titleLabel.rightAnchor)
		titleLabel.rightAnchor.constraint(equalTo: editButton.leftAnchor)
		editButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
		editButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		
		editButton.addTarget(self, action: #selector(FoodHeaderView._didTapEdit), for: .touchUpInside)
	}
    
    private func updateViews() {
        editButton.isHidden = !isEditButtonVisible
        leftConstraint?.constant = leftInset
    }
}
