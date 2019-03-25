//
//  UserAuthPageViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/21/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import UIKit

class UserAuthPageViewController: UIViewController {
    var selectedUserStatusSegmentedControlSegment: UserStatusSegmentedControlSegment = .existing {
        didSet { update() }
    }
    
    let existingUserAuthViewController = UserAuthViewController()
    let newUserAuthViewController = UserAuthViewController()
    
    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private let userStatusSegmentedControl = UISegmentedControl()
    
    private lazy var userStatusSegmentedControlValueChangedTarget = Target(action: userStatusSegmentedControlValueChangedTargetAction)
    
    private struct Constants {
        static let existingUserStatusSegmentedControlSegmentTitle = "Sign In"
        static let newUserStatusSegmentedControlSegmentTitle = "Sign Up"
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureExistingUserAuthViewController()
        configureNewUserAuthViewController()
        configureUserStatusSegmentedControl()
        configureNavigation()
        addChildren()
        update()
        setViewController()
    }
    
    // MARK: - Setup Methods
    private func addChildren() {
        add(pageViewController)
        pageViewController.view.edgesToSuperview()
    }
    
    private func configureNavigation() {
        self.navigationItem.titleView = userStatusSegmentedControl
    }
    
    private func configureExistingUserAuthViewController() {
        existingUserAuthViewController.viewModel.userStatus = .existing
    }
    
    private func configureNewUserAuthViewController() {
        newUserAuthViewController.viewModel.userStatus = .new
    }
    
    private func configureUserStatusSegmentedControl() {
        UserStatusSegmentedControlSegment.allCases
            .forEach { self.userStatusSegmentedControl.insertSegment(withTitle: $0.title, at: $0.rawValue, animated: false) }
        userStatusSegmentedControl.add(userStatusSegmentedControlValueChangedTarget, for: .valueChanged)
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
    private func userStatusSegmentedControlValueChangedTargetAction() {
        guard let segment = UserStatusSegmentedControlSegment(rawValue: userStatusSegmentedControl.selectedSegmentIndex)
            else { return }
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
