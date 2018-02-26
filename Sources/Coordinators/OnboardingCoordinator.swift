//
//  OnboardingCoordinator.swift
//  MementoFM
//
//  Created by Daniel on 25/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

protocol OnboardingCoordinatorDelegate: class {
  func onboardingCoordinatorDidFinish(_ coordinator: OnboardingCoordinator)
}

class OnboardingCoordinator: NavigationFlowCoordinator, IgnoredTagsPresenter, SyncPresenter {
  var childCoordinators: [Coordinator] = []
  var onDidFinish: (() -> Void)?

  let navigationController: NavigationController
  let dependencies: AppDependency

  weak var delegate: OnboardingCoordinatorDelegate?

  init(window: UIWindow, dependencies: AppDependency) {
    self.navigationController = NavigationController()
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
    viewController.title = "Welcome!".unlocalized
    if alreadyHasUsername {
      let forwardButton = BlockBarButtonItem(image: R.image.iconForward(), style: .plain) { [unowned self] in
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
    navigationController.isInteractivePopGestureEnabled = false
    navigationController.pushViewController(viewController, animated: true)
  }
}

extension OnboardingCoordinator: EnterUsernameViewModelDelegate {
  func enterUsernameViewModelDidFinish(_ viewModel: EnterUsernameViewModel) {
    showIgnoredTagsViewController(animated: true)
  }
}

extension OnboardingCoordinator: IgnoredTagsViewModelDelegate {
  func ignoredTagsViewModelDidSaveChanges(_ viewModel: IgnoredTagsViewModel) {
    showSyncViewController()
  }
}

extension OnboardingCoordinator: SyncViewModelDelegate {
  func syncViewModelDidFinishLoading(_ viewModel: SyncViewModel) {
    dependencies.userService.didFinishOnboarding = true
    delegate?.onboardingCoordinatorDidFinish(self)
  }
}
