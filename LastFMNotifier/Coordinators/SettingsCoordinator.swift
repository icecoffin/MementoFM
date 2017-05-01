//
//  SettingsCoordinator.swift
//  LastFMNotifier
//
//  Created by Daniel on 16/12/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit

protocol SettingsCoordinatorDelegate: class {
  func settingsCoordinatorDidChangeUsername(_ coordinator: SettingsCoordinator)
}

class SettingsCoordinator: NavigationFlowCoordinator, IgnoredTagsPresenter {
  typealias Dependencies = HasRealmGateway & HasUserDataStorage & HasGeneralNetworkService

  var childCoordinators: [Coordinator] = []

  let navigationController: UINavigationController
  let dependencies: Dependencies

  weak var delegate: SettingsCoordinatorDelegate?

  init(navigationController: UINavigationController,
       dependencies: Dependencies) {
    self.navigationController = navigationController
    self.dependencies = dependencies
  }

  func start() {
    let settingsViewModel = SettingsViewModel()
    settingsViewModel.delegate = self
    let settingsViewController = SettingsViewController(viewModel: settingsViewModel)
    settingsViewController.title = "Settings".unlocalized
    navigationController.pushViewController(settingsViewController, animated: false)
  }
}

extension SettingsCoordinator: SettingsViewModelDelegate {
  func settingsViewModelDidRequestOpenIgnoredTags(_ viewModel: SettingsViewModel) {
    let viewController = makeIgnoredTagsViewController(dependencies: dependencies, shouldAddDefaultTags: false)
    navigationController.pushViewController(viewController, animated: true)
  }

  func settingsViewModelDidRequestChangeUser(_ viewModel: SettingsViewModel) {
    let viewModel = EnterUsernameViewModel(dependencies: dependencies)
    viewModel.delegate = self
    let viewController = EnterUsernameViewController(viewModel: viewModel)
    viewController.title = "Change Username".unlocalized
    viewController.navigationItem.leftBarButtonItem = makeBackButton()
    navigationController.pushViewController(viewController, animated: true)
  }

  func settingsViewModelDidRequestOpenAbout(_ viewModel: SettingsViewModel) {
    let viewController = AboutViewController()
    viewController.title = "About".unlocalized
    viewController.navigationItem.leftBarButtonItem = makeBackButton()
    viewController.hidesBottomBarWhenPushed = true
    navigationController.pushViewController(viewController, animated: true)
  }
}

extension SettingsCoordinator: EnterUsernameViewModelDelegate {
  func enterUsernameViewModelDidFinish(_ viewModel: EnterUsernameViewModel) {
    navigationController.dismiss(animated: true, completion: nil)
    dependencies.generalNetworkService.cancelPendingRequests()
    delegate?.settingsCoordinatorDidChangeUsername(self)
  }
}

extension SettingsCoordinator: IgnoredTagsViewModelDelegate {
  func ignoredTagsViewModelDidSaveChanges(_ viewModel: IgnoredTagsViewModel) {
    navigationController.popViewController(animated: true)
  }
}
