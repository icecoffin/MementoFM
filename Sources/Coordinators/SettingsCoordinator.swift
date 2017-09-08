//
//  SettingsCoordinator.swift
//  MementoFM
//
//  Created by Daniel on 16/12/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit

protocol SettingsCoordinatorDelegate: class {
  func settingsCoordinatorDidChangeUsername(_ coordinator: SettingsCoordinator)
}

class SettingsCoordinator: NavigationFlowCoordinator, IgnoredTagsPresenter, SyncPresenter {
  var childCoordinators: [Coordinator] = []
  var onDidFinish: (() -> Void)?

  let navigationController: NavigationController
  let dependencies: AppDependency

  weak var delegate: SettingsCoordinatorDelegate?

  init(navigationController: NavigationController, dependencies: AppDependency) {
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
    showSyncViewController()
  }

  func showSyncViewController() {
    let syncViewController = makeSyncViewController(dependencies: dependencies)
    syncViewController.hidesBottomBarWhenPushed = true
    navigationController.pushViewController(syncViewController, animated: true)
    navigationController.setNavigationBarHidden(true, animated: false)
  }
}

extension SettingsCoordinator: IgnoredTagsViewModelDelegate {
  func ignoredTagsViewModelDidSaveChanges(_ viewModel: IgnoredTagsViewModel) {
    navigationController.popViewController(animated: true)
  }
}

extension SettingsCoordinator: SyncViewModelDelegate {
  func syncViewModelDidFinishLoading(_ viewModel: SyncViewModel) {
    delegate?.settingsCoordinatorDidChangeUsername(self)
  }
}
