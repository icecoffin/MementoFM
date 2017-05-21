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

  let navigationController: NavigationController
  let dependencies: AppDependency
  var realmGateway: HasRealmGateway {
    return dependencies
  }

  weak var delegate: OnboardingCoordinatorDelegate?

  init(window: UIWindow, dependencies: AppDependency) {
    self.navigationController = NavigationController()
    window.rootViewController = self.navigationController
    self.dependencies = dependencies
  }

  func start() {
    let alreadyHasUsername = !dependencies.userDataStorage.username.isEmpty
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
      let forwardButton = BlockBarButtonItem(image: #imageLiteral(resourceName: "icon_forward"), style: .plain) { [unowned self] in
        self.showIgnoredTagsViewController(animated: true)
      }
      viewController.navigationItem.rightBarButtonItem = forwardButton
    }
    navigationController.pushViewController(viewController, animated: true)
  }

  fileprivate func showIgnoredTagsViewController(animated: Bool) {
    let viewController = makeIgnoredTagsViewController(dependencies: dependencies, shouldAddDefaultTags: true)
    navigationController.pushViewController(viewController, animated: animated)
  }

  fileprivate func showSyncViewController() {
    let viewController = makeSyncViewController(dependencies: dependencies)
    navigationController.setNavigationBarHidden(true, animated: false)
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
    dependencies.userDataStorage.didFinishOnboarding = true
    delegate?.onboardingCoordinatorDidFinish(self)
  }
}
