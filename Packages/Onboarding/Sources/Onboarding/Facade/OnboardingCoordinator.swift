//
//  OnboardingCoordinator.swift
//  MementoFM
//
//  Created by Daniel on 25/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit
import Core
import CoreUI
import Sync

// MARK: - OnboardingCoordinatorDelegate

public protocol OnboardingCoordinatorDelegate: AnyObject {
    func onboardingCoordinatorDidFinish(_ coordinator: OnboardingCoordinator)
}

// MARK: - OnboardingCoordinator

public final class OnboardingCoordinator: NavigationFlowCoordinator {
    // MARK: - Private properties

    private let dependencies: OnboardingDependencies
    private let popTracker: NavigationControllerPopTracker

    // MARK: - Public properties

    public var childCoordinators: [Coordinator] = []
    public var didFinish: (() -> Void)?

    public let navigationController: UINavigationController

    public weak var delegate: OnboardingCoordinatorDelegate?

    // MARK: - Init

    public init(window: UIWindow, dependencies: OnboardingDependencies) {
        navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true
        popTracker = NavigationControllerPopTracker(navigationController: navigationController)
        window.rootViewController = self.navigationController
        self.dependencies = dependencies
    }

    // MARK: - Public methods

    public func start() {
        let alreadyHasUsername = !dependencies.userService.username.isEmpty
        showEnterUsernameViewController(alreadyHasUsername: alreadyHasUsername)
        if alreadyHasUsername {
            showIgnoredTagsViewController(animated: false)
        }
    }

    // MARK: - Private methods

    private func showEnterUsernameViewController(alreadyHasUsername: Bool) {
        let viewModel = EnterUsernameViewModel(dependencies: dependencies)
        viewModel.delegate = self
        let viewController = EnterUsernameViewController(viewModel: viewModel)
        viewController.navigationItem.backButtonDisplayMode = .minimal
        viewController.title = "Welcome!".unlocalized
        if alreadyHasUsername {
            let forwardButton = BlockBarButtonItem(image: .arrowRight, style: .plain) { [unowned self] in
                self.showIgnoredTagsViewController(animated: true)
            }
            viewController.navigationItem.rightBarButtonItem = forwardButton
        }
        navigationController.pushViewController(viewController, animated: true)
    }

    private func showIgnoredTagsViewController(animated: Bool) {
        let viewModel = IgnoredTagsViewModel(dependencies: dependencies, shouldAddDefaultTags: true)
        viewModel.delegate = self
        let viewController = IgnoredTagsViewController(viewModel: viewModel)
        viewController.title = "Ignored Tags".unlocalized

        let addButton = BlockBarButtonItem(image: .plus, style: .plain) { [unowned viewModel] in
            viewModel.addNewIgnoredTag()
        }

        let doneButton = BlockBarButtonItem(image: .checkmark, style: .plain) { [unowned viewModel] in
            viewModel.saveChanges()
        }

        viewController.navigationItem.rightBarButtonItems = [doneButton, addButton]

        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: animated)
    }

    private func showSyncViewController() {
        let syncCoordinator = dependencies.syncCoordinatorFactory(navigationController, popTracker)
        syncCoordinator.delegate = self
        addChildCoordinator(syncCoordinator)
        syncCoordinator.start()
    }
}

// MARK: - EnterUsernameViewModelDelegate

extension OnboardingCoordinator: EnterUsernameViewModelDelegate {
    func enterUsernameViewModelDidFinish(_ viewModel: EnterUsernameViewModel) {
        showIgnoredTagsViewController(animated: true)
    }
}

// MARK: - IgnoredTagsViewModelDelegate

extension OnboardingCoordinator: IgnoredTagsViewModelDelegate {
    func ignoredTagsViewModelDidSaveChanges(_ viewModel: IgnoredTagsViewModel) {
        showSyncViewController()
    }
}

// MARK: - SyncCoordinatorDelegate

extension OnboardingCoordinator: SyncCoordinatorDelegate {
    public func syncCoordinatorDidFinishSync(_ coordinator: SyncCoordinator) {
        dependencies.userService.didFinishOnboarding = true
        delegate?.onboardingCoordinatorDidFinish(self)
    }
}
