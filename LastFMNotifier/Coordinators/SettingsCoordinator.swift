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
    navigationController.pushViewController(settingsViewController, animated: false)
  }
}

extension SettingsCoordinator: SettingsViewModelDelegate {
  func settingsViewModelDidRequestOpenIgnoredTags(_ viewModel: SettingsViewModel) {
    let viewController = makeIgnoredTagsViewController(dependencies: dependencies)
    navigationController.pushViewController(viewController, animated: true)
  }

  func settingsViewModelDidRequestChangeUser(_ viewModel: SettingsViewModel) {
    let viewModel = EnterUsernameViewModel(dependencies: dependencies)
    viewModel.delegate = self
    let viewController = EnterUsernameViewController(viewModel: viewModel)
    viewController.configureForModalPresentation()
    navigationController.present(viewController, animated: true, completion: nil)
  }

  func settingsViewModelDidRequestOpenAbout(_ viewModel: SettingsViewModel) {
    let viewController = AboutViewController()
    viewController.navigationItem.leftBarButtonItem = createBackButton()
    viewController.hidesBottomBarWhenPushed = true
    navigationController.pushViewController(viewController, animated: true)
  }
}

extension SettingsCoordinator: EnterUsernameViewModelDelegate {
  func enterUsernameViewModel(_ viewModel: EnterUsernameViewModel, didFinishWithAction action: EnterUsernameViewModelAction) {
    navigationController.dismiss(animated: true, completion: nil)
    if case .submit = action {
      dependencies.generalNetworkService.cancelPendingRequests()
      delegate?.settingsCoordinatorDidChangeUsername(self)
    }
  }
}

extension SettingsCoordinator: IgnoredTagsViewModelDelegate {
  func ignoredTagsViewModelDidSaveChanges(_ viewModel: IgnoredTagsViewModel) {
    navigationController.popViewController(animated: true)
  }
}
