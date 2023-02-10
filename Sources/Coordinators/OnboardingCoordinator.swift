//
//  OnboardingCoordinator.swift
//  MementoFM
//
//  Created by Daniel on 25/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit
import Core

// MARK: - OnboardingCoordinatorDelegate

protocol OnboardingCoordinatorDelegate: AnyObject {
    func onboardingCoordinatorDidFinish(_ coordinator: OnboardingCoordinator)
}

// MARK: - OnboardingCoordinator

final class OnboardingCoordinator: NavigationFlowCoordinator, IgnoredTagsPresenter, SyncPresenter {
    var childCoordinators: [Coordinator] = []
    var didFinish: (() -> Void)?

    let navigationController: UINavigationController
    let dependencies: AppDependency

    weak var delegate: OnboardingCoordinatorDelegate?

    init(window: UIWindow, dependencies: AppDependency) {
        self.navigationController = UINavigationController()
        self.navigationController.navigationBar.prefersLargeTitles = true
        window.rootViewController = self.navigationController
        self.dependencies = dependencies
    }

    func start() {
        let alreadyHasUsername = !dependencies.userService.username.isEmpty
        showEnterUsernameViewController(alreadyHasUsername: alreadyHasUsername)
        if alreadyHasUsername {
            showIgnoredTagsViewController(animated: false)
        }
    }

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
        let viewController = makeIgnoredTagsViewController(dependencies: dependencies, shouldAddDefaultTags: true)
        navigationController.pushViewController(viewController, animated: animated)
    }

    private func showSyncViewController() {
        let viewController = makeSyncViewController(dependencies: dependencies)
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.interactivePopGestureRecognizer?.isEnabled = false
        navigationController.pushViewController(viewController, animated: true)
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

// MARK: - SyncViewModelDelegate

extension OnboardingCoordinator: SyncViewModelDelegate {
    func syncViewModelDidFinishLoading(_ viewModel: SyncViewModel) {
        dependencies.userService.didFinishOnboarding = true
        delegate?.onboardingCoordinatorDidFinish(self)
    }
}
