
//
//  Blurable.swift
//  Sammys
//
//  Created by Natanel Niazoff on 6/17/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol Blurable where Self: UIViewController {
    var blurView: UIVisualEffectView { get }
    var blurEffect : UIBlurEffect { get }
}

extension Blurable {
    func initializeBlurView() {
        view.backgroundColor = nil
        blurView.effect = nil
        blurView.contentView.alpha = 0
    }
    
    func animateBlurViewIn(withDuration duration: TimeInterval, completed: ((Bool) -> Void)? = nil) {
        blurView.effect = nil
        blurView.contentView.alpha = 0
        UIView.animate(withDuration: duration, animations: {
            self.blurView.effect = self.blurEffect
            self.blurView.contentView.alpha = 1
        }, completion: completed)
    }
    
    func animateBlurViewOut(withDuration duration: TimeInterval, completed: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.blurView.effect = nil
            self.blurView.contentView.alpha = 0
        }, completion: completed)
    }
}

class BlurAnimationController: NSObject {
    private var duration: TimeInterval
    
    init(duration: TimeInterval) {
        self.duration = duration
    }
}

extension BlurAnimationController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to) as? (UIViewController & Blurable) else { transitionContext.completeTransition(true); return }
        toViewController.initializeBlurView()
        let container = transitionContext.containerView
        container.addSubview(toViewController.view)
        toViewController.animateBlurViewIn(withDuration: duration) { didComplete in
            transitionContext.completeTransition(didComplete)
        }
    }
}

extension UIViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presented is Blurable ? BlurAnimationController(duration: 0.5) : nil
    }
    
    func setupAndPresentBlurable(_ viewController: (UIViewController & Blurable)) {
        viewController.view.backgroundColor = nil
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.transitioningDelegate = self
        present(viewController, animated: true, completion: nil)
    }
}
