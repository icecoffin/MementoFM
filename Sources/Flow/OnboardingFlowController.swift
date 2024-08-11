//
//  OnboardingFlowController.swift
//  MementoFM
//
//  Created by Dani on 11.08.2024.
//  Copyright © 2024 icecoffin. All rights reserved.
//

import UIKit

// MARK: - OnboardingFlowControllerDelegate

protocol OnboardingFlowControllerDelegate: AnyObject {
    func onboardingFlowControllerDidFinish(_ flowController: OnboardingFlowController)
}

// MARK: - OnboardingFlowController

final class OnboardingFlowController: UIViewController, FlowController, IgnoredTagsPresenter, SyncPresenter {
    private let dependencies: AppDependency
    private let embeddedNavigationController: UINavigationController

    weak var delegate: OnboardingFlowControllerDelegate?

    init(dependencies: AppDependency) {
        self.dependencies = dependencies
        self.embeddedNavigationController = UINavigationController()

        super.init(nibName: nil, bundle: nil)

        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        embeddedNavigationController.navigationBar.prefersLargeTitles = true
        add(child: embeddedNavigationController)

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
        viewController.title = "Welcome!".unlocalized
        viewController.navigationItem.backButtonDisplayMode = .minimal

        if alreadyHasUsername {
            let forwardButton = BlockBarButtonItem(image: .arrowRight, style: .plain) { [unowned self] in
                self.showIgnoredTagsViewController(animated: true)
            }
            viewController.navigationItem.rightBarButtonItem = forwardButton
        }

        embeddedNavigationController.pushViewController(viewController, animated: false)
    }

    private func showIgnoredTagsViewController(animated: Bool) {
        let viewController = makeIgnoredTagsViewController(dependencies: dependencies, shouldAddDefaultTags: true)
        embeddedNavigationController.pushViewController(viewController, animated: animated)
    }

    private func showSyncViewController() {
        let viewController = makeSyncViewController(dependencies: dependencies)
        embeddedNavigationController.setNavigationBarHidden(true, animated: false)
        embeddedNavigationController.interactivePopGestureRecognizer?.isEnabled = false
        embeddedNavigationController.pushViewController(viewController, animated: true)
    }
}

// MARK: - EnterUsernameViewModelDelegate

extension OnboardingFlowController: EnterUsernameViewModelDelegate {
    func enterUsernameViewModelDidFinish(_ viewModel: EnterUsernameViewModel) {
        showIgnoredTagsViewController(animated: true)
    }
}

// MARK: - IgnoredTagsViewModelDelegate

extension OnboardingFlowController: IgnoredTagsViewModelDelegate {
    func ignoredTagsViewModelDidSaveChanges(_ viewModel: IgnoredTagsViewModel) {
        showSyncViewController()
    }
}

// MARK: - SyncViewModelDelegate

extension OnboardingFlowController: SyncViewModelDelegate {
    func syncViewModelDidFinishLoading(_ viewModel: SyncViewModel) {
        dependencies.userService.didFinishOnboarding = true
        delegate?.onboardingFlowControllerDidFinish(self)
    }
}
