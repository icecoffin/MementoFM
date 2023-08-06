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
import IgnoredTagsInterface
import EnterUsername

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
        var forwardButtonAction: (() -> Void)?
        if alreadyHasUsername {
            forwardButtonAction = { [unowned self] in
                self.showIgnoredTagsViewController(animated: true)
            }
        }

        let enterUsernameCoordinator = dependencies.enterUsernameCoordinatorFactory.makeEnterUsernameCoordinator(
            navigationController: navigationController,
            configuration: .init(
                title: "Welcome!".unlocalized,
                showsBackButtonTitle: false,
                forwardButtonAction: forwardButtonAction
            )
        )
        enterUsernameCoordinator.delegate = self
        addChildCoordinator(enterUsernameCoordinator)
        enterUsernameCoordinator.start()
    }

    private func showIgnoredTagsViewController(animated: Bool) {
        let ignoredTagsCoordinator = dependencies.ignoredTagsCoordinatorFactory.makeIgnoredCoordinator(
            navigationController: navigationController,
            shouldAddDefaultTags: true,
            showAnimated: animated
        )
        ignoredTagsCoordinator.delegate = self
        addChildCoordinator(ignoredTagsCoordinator)
        ignoredTagsCoordinator.start()
    }

    private func showSync() {
        let syncCoordinator = dependencies.syncCoordinatorFactory.makeSyncCoordinator(navigationController: navigationController)
        syncCoordinator.delegate = self
        addChildCoordinator(syncCoordinator)
        syncCoordinator.start()
    }
}

// MARK: - EnterUsernameViewModelDelegate

extension OnboardingCoordinator: EnterUsernameCoordinatorDelegate {
    public func enterUsernameCoordinatorDidFinish(_ coordinator: EnterUsernameCoordinator) {
        showIgnoredTagsViewController(animated: true)
    }
}

// MARK: - SyncCoordinatorDelegate

extension OnboardingCoordinator: SyncCoordinatorDelegate {
    public func syncCoordinatorDidFinishSync(_ coordinator: SyncCoordinator) {
        dependencies.userService.didFinishOnboarding = true
        delegate?.onboardingCoordinatorDidFinish(self)
    }
}

// MARK: - IgnoredTagsCoordinatorDelegate

extension OnboardingCoordinator: IgnoredTagsCoordinatorDelegate {
    public func ignoredTagsCoordinatorDidSaveChanges(_ coordinator: any IgnoredTagsCoordinatorProtocol) {
        showSync()
    }
}
