//
//  FoodHeaderView.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/18/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class FoodHeaderView: UICollectionReusableView {
    var didTapEdit: ((FoodHeaderView) -> Void)?
    
    private var _titleLabel = UILabel()
    private var _editButton = UIButton(type: .system)
    public var titleLabel: UILabel {
        return _titleLabel
    }
    public var editButton: UIButton {
        return _editButton
    }
    
    struct Constants {
        static let edit = "Edit"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup() {
        // setup titleLabel
        addSubview(_titleLabel)
        _titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        _titleLabel.textColor = .black
        _titleLabel.translatesAutoresizingMaskIntoConstraints = false
        _titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        _titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        _titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        // setup editButton
        addSubview(_editButton)
        _editButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        _editButton.translatesAutoresizingMaskIntoConstraints = false
        _editButton.setTitle(Constants.edit, for: .normal)
        _editButton.leftAnchor.constraint(equalTo: _titleLabel.rightAnchor).isActive = true
        _titleLabel.rightAnchor.constraint(equalTo: _editButton.leftAnchor).isActive = true
        _editButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        _editButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        _editButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        _editButton.addTarget(self, action: #selector(FoodHeaderView._didTapEdit), for: .touchUpInside)
    }
    
    @objc func _didTapEdit() {
        didTapEdit?(self)
    }
}
