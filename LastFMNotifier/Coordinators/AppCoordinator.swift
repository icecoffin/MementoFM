//
//  AppCoordinator.swift
//  GlossLite
//
//  Created by Daniel on 16/11/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit

class AppCoordinator: Coordinator {
  var childCoordinators: [Coordinator] = []

  private let window: UIWindow
  private let realmGateway = RealmGateway(defaultRealm: RealmFactory.realm(), getWriteRealm: {
    return RealmFactory.realm()
  })
  fileprivate let userDataStorage: UserDataStorage

  init(window: UIWindow, userDataStorage: UserDataStorage = UserDataStorage()) {
    self.window = window
    self.userDataStorage = userDataStorage
  }

  func start() {
    removeAllChildren()

    if userDataStorage.username != nil {
      startMainFlow()
    } else {
      startEnterUsernameFlow()
    }
  }

  func startMainFlow() {
    let mainFlowCoordinator = MainFlowCoordinator(window: window, realmGateway: realmGateway)
    mainFlowCoordinator.delegate = self
    addChildCoordinator(mainFlowCoordinator)
    startChildren()
  }

  func startEnterUsernameFlow() {
    let enterUsernameViewModel = EnterUsernameViewModel(realmGateway: realmGateway, userDataStorage: userDataStorage)
    let enterUsernameViewController = EnterUsernameViewController(viewModel: enterUsernameViewModel)
    enterUsernameViewModel.delegate = self

    window.rootViewController = enterUsernameViewController
  }
}

extension AppCoordinator: EnterUsernameViewModelDelegate {
  func enterUsernameViewModelDidFinish(_ viewModel: EnterUsernameViewModel) {
    start()
  }

  func enterUsernameViewModelDidRequestToClose(_ viewModel: EnterUsernameViewModel) {

  }
}

extension AppCoordinator: MainFlowCoordinatorDelegate {
  func mainFlowCoordinatorDidChangeUsername(_ coordinator: MainFlowCoordinator) {
    start()
  }
}
