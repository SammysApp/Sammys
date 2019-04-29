//
//  UserAuthPageViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/21/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class UserAuthPageViewController: UIViewController {
    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    
    let userStatusSegmentedControl = UISegmentedControl()
    
    let existingUserAuthViewController = UserAuthViewController()
    let newUserAuthViewController = UserAuthViewController()
    
    private lazy var userStatusSegmentedControlValueChangedTarget = Target(action: userStatusSegmentedControlValueChangedAction)
    private lazy var cancelBarButtonItemTarget = Target(action: didCancelHandler)
    
    var selectedUserStatusSegmentedControlSegment: UserStatusSegmentedControlSegment = .existing {
        didSet { update() }
    }
    
    var didCancelHandler: () -> Void = {}
    
    private struct Constants {
        static let navigationBarTintColor = #colorLiteral(red: 0.3294117647, green: 0.1921568627, blue: 0.09411764706, alpha: 1)
        
        static let existingUserStatusSegmentedControlSegmentTitle = "Sign In"
        static let newUserStatusSegmentedControlSegmentTitle = "Sign Up"
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUserStatusSegmentedControl()
        configureExistingUserAuthViewController()
        configureNewUserAuthViewController()
        addChildren()
        configureNavigation()
        update()
        
        setViewController()
    }
    
    // MARK: - Setup Methods
    private func addChildren() {
        add(pageViewController)
        pageViewController.view.edgesToSuperview()
    }
    
    private func configureNavigation() {
        self.navigationController?.navigationBar.tintColor = Constants.navigationBarTintColor
        self.navigationItem.titleView = userStatusSegmentedControl
        self.navigationItem.leftBarButtonItem = .init(barButtonSystemItem: .cancel, target: cancelBarButtonItemTarget)
    }
    
    private func configureUserStatusSegmentedControl() {
        UserStatusSegmentedControlSegment.allCases
            .forEach { self.userStatusSegmentedControl.insertSegment(withTitle: $0.title, at: $0.rawValue, animated: false) }
        userStatusSegmentedControl.add(userStatusSegmentedControlValueChangedTarget, for: .valueChanged)
    }
    
    private func configureExistingUserAuthViewController() {
        existingUserAuthViewController.viewModel.userStatus = .existing
    }
    
    private func configureNewUserAuthViewController() {
        newUserAuthViewController.viewModel.userStatus = .new
    }
    
    func update() {
        userStatusSegmentedControl.selectedSegmentIndex = selectedUserStatusSegmentedControlSegment.rawValue
    }
    
    func setViewController(animated: Bool = false) {
        switch selectedUserStatusSegmentedControlSegment {
        case .existing: pageViewController.setViewControllers([existingUserAuthViewController], direction: .reverse, animated: animated, completion: nil)
        case .new: pageViewController.setViewControllers([newUserAuthViewController], direction: .forward, animated: animated, completion: nil)
        }
    }
    
    // MARK: - Target Actions
    private func userStatusSegmentedControlValueChangedAction() {
        guard let segment = UserStatusSegmentedControlSegment(rawValue: userStatusSegmentedControl.selectedSegmentIndex) else { return }
        
        selectedUserStatusSegmentedControlSegment = segment
        setViewController(animated: true)
    }
}

extension UserAuthPageViewController {
    enum UserStatusSegmentedControlSegment: Int, CaseIterable {
        case existing, new
        
        var title: String {
            switch self {
            case .existing: return Constants.existingUserStatusSegmentedControlSegmentTitle
            case .new: return Constants.newUserStatusSegmentedControlSegmentTitle
            }
        }
    }
}
