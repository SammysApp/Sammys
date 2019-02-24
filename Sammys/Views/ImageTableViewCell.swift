//
//  ImageTableViewCell.swift
//  Sammys
//
//  Created by Natanel Niazoff on 2/21/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit
import TinyConstraints

class ImageTableViewCell: UITableViewCell {
    private let _imageView = UIImageView()
    private let _textLabel = UILabel()
    
    override var imageView: UIImageView { get { return _imageView } }
    override var textLabel: UILabel { get { return _textLabel } }
    
    private struct Constants {
        static let textLabelOffest: CGFloat = 20
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setUp()
    }
    
    private func setUp() {
        [imageView, textLabel]
            .forEach { self.contentView.addSubview($0) }
        imageView.edgesToSuperview()
        textLabel.top(to: self.contentView, offset: Constants.textLabelOffest)
    }
}
