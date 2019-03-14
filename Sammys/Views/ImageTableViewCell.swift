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
    
    var prepareForReuseHandler: (() -> Void)?
    
    private struct Constants {
        static let textLabelOffest: CGFloat = 20
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func prepareForReuse() { prepareForReuseHandler?() }
    
    private func setUp() {
        [imageView, textLabel]
            .forEach { self.contentView.addSubview($0) }
        imageView.edgesToSuperview()
        textLabel.top(to: self.contentView, offset: Constants.textLabelOffest)
        textLabel.centerX(to: self.contentView)
    }
}
