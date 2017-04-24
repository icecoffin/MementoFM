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

class SettingsCoordinator: NavigationFlowCoordinator {
  var childCoordinators: [Coordinator] = []

  let navigationController: UINavigationController
  fileprivate let realmGateway: RealmGateway
  fileprivate let userDataStorage: UserDataStorage

  weak var delegate: SettingsCoordinatorDelegate?

  init(navigationController: UINavigationController,
       realmGateway: RealmGateway,
       userDataStorage: UserDataStorage = UserDataStorage()) {
    self.navigationController = navigationController
    self.realmGateway = realmGateway
    self.userDataStorage = userDataStorage
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
    let viewModel = IgnoredTagsViewModel(realmGateway: realmGateway)
    viewModel.delegate = self
    let viewController = IgnoredTagsViewController(viewModel: viewModel)
    viewController.navigationItem.leftBarButtonItem = createBackButton()

    let rightView = IgnoredTagsNavigationRightView()
    rightView.onAddTapped = { [unowned viewModel] in
      viewModel.addNewIgnoredTag()
    }
    rightView.onSaveTapped = { [unowned viewModel] in
      viewModel.saveChanges()
    }
    rightView.sizeToFit()
    let rightBarButtonItem = UIBarButtonItem(customView: rightView)
    viewController.navigationItem.rightBarButtonItem = rightBarButtonItem

    viewController.hidesBottomBarWhenPushed = true
    navigationController.pushViewController(viewController, animated: true)
  }

  func settingsViewModelDidRequestChangeUser(_ viewModel: SettingsViewModel) {
    let viewModel = EnterUsernameViewModel(realmGateway: realmGateway, userDataStorage: userDataStorage)
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
  func enterUsernameViewModelDidRequestToClose(_ viewModel: EnterUsernameViewModel) {
    navigationController.dismiss(animated: true, completion: nil)
  }

  func enterUsernameViewModelDidFinish(_ viewModel: EnterUsernameViewModel) {
    navigationController.dismiss(animated: true, completion: nil)
    delegate?.settingsCoordinatorDidChangeUsername(self)
  }
}

extension SettingsCoordinator: IgnoredTagsViewModelDelegate {
  func ignoredTagsViewModelDidSaveChanges(_ viewModel: IgnoredTagsViewModel) {
    navigationController.popViewController(animated: true)
  }
}
