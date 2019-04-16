//
//  BlurLoadingView.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/15/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class BlurLoadingView: UIView {
    var image: UIImage? {
        didSet { update() }
    }
    
    var blurEffectStyle = UIBlurEffect.Style.dark {
        didSet { update() }
    }
    
    var cornerRadiusMultiplier = CGFloat(0.25) {
        didSet { update() }
    }
    
    var hidesWhenStopped = true
    
    private lazy var imageView = UIImageView(image: image)
    
    private lazy var blurEffect = UIBlurEffect(style: blurEffectStyle)
    
    private let blurEffectView = UIVisualEffectView()
    private let vibrancyEffectView = UIVisualEffectView()
    
    private struct Constants {
        static let rotationKeyPath = "transform.rotation"
        static let imageViewRotationAnimationKey = "rotation"
    }
    
    override init(frame: CGRect) { super.init(frame: frame); setUp() }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    func startAnimating() {
        if hidesWhenStopped { self.isHidden = false }
        startImageViewRotationAnimation()
    }
    
    func stopAnimating() {
        if hidesWhenStopped { self.isHidden = true }
        stopImageViewRotationAnimation()
    }
    
    private func setUp() {
        self.addSubview(blurEffectView)
        blurEffectView.edgesToSuperview()
        
        blurEffectView.contentView.addSubview(vibrancyEffectView)
        vibrancyEffectView.edgesToSuperview()
        
        vibrancyEffectView.contentView.addSubview(imageView)
        imageView.centerInSuperview()
        
        update()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        update()
    }
    
    private func update() {
        let maskPath = UIBezierPath(roundedRect: .init(x: 0, y: 0, width: self.frame.width, height: self.frame.height), cornerRadius: self.frame.height * cornerRadiusMultiplier).cgPath
        let mask = CAShapeLayer()
        mask.path = maskPath
        self.layer.mask = mask
        
        imageView.image = image
        
        blurEffect = UIBlurEffect(style: blurEffectStyle)
        blurEffectView.effect = blurEffect
        vibrancyEffectView.effect = UIVibrancyEffect(blurEffect: blurEffect)
    }
    
    private func startImageViewRotationAnimation(duration: TimeInterval = 1) {
        guard imageView.layer.animation(forKey: Constants.imageViewRotationAnimationKey) == nil else { return }
        let animation = CABasicAnimation(keyPath: Constants.rotationKeyPath)
        animation.duration = duration
        animation.repeatCount = .infinity
        animation.fromValue = 0.0
        animation.toValue = .pi * 2.0
        imageView.layer.add(animation, forKey: Constants.imageViewRotationAnimationKey)
    }
    
    private func stopImageViewRotationAnimation() {
        guard imageView.layer.animation(forKey: Constants.imageViewRotationAnimationKey) != nil else { return }
        imageView.layer.removeAnimation(forKey: Constants.imageViewRotationAnimationKey)
    }
}
