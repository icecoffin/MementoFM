//
//  OnboardingCoordinator.swift
//  LastFMNotifier
//
//  Created by Daniel on 25/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

class OnboardingCoordinator: NavigationFlowCoordinator {
  var childCoordinators: [Coordinator] = []

  let navigationController: UINavigationController
  private let realmGateway: RealmGateway

  init(window: UIWindow, realmGateway: RealmGateway) {
    self.navigationController = UINavigationController()
    window.rootViewController = self.navigationController
    self.realmGateway = realmGateway
  }

  func start() {
    showEnterUsernameViewController()
  }

  private func showEnterUsernameViewController() {

  }

  fileprivate func showIgnoredTagsViewController() {

  }
}

extension OnboardingCoordinator: EnterUsernameViewModelDelegate {
  func enterUsernameViewModel(_ viewModel: EnterUsernameViewModel, didFinishWithAction action: EnterUsernameViewModelAction) {

  }
}
