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
  func settingsViewModelDidRequestChangeUser(_ viewModel: SettingsViewModel) {
    let enterUsernameViewModel = EnterUsernameViewModel(realmGateway: realmGateway, userDataStorage: userDataStorage)
    enterUsernameViewModel.delegate = self
    let enterUsernameViewController = EnterUsernameViewController(viewModel: enterUsernameViewModel)
    enterUsernameViewController.configureForModalPresentation()
    navigationController.present(enterUsernameViewController, animated: true, completion: nil)
  }

  func settingsViewModelDidRequestOpenAbout(_ viewModel: SettingsViewModel) {
    let aboutViewController = AboutViewController()
    aboutViewController.navigationItem.leftBarButtonItem = createBackButton()
    aboutViewController.hidesBottomBarWhenPushed = true
    navigationController.pushViewController(aboutViewController, animated: true)
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
