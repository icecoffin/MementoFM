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
  fileprivate let dependencies: AppDependency

  init(window: UIWindow, dependencies: AppDependency = AppDependency.default) {
    self.window = window
    self.dependencies = dependencies
  }

  func start() {
    removeAllChildren()

    if dependencies.userDataStorage.didFinishOnboarding {
      startMainFlow()
    } else {
      startOnboardingFlow()
    }
  }

  func startMainFlow() {
    let mainFlowCoordinator = MainFlowCoordinator(window: window, dependencies: dependencies)
    mainFlowCoordinator.delegate = self
    addChildCoordinator(mainFlowCoordinator)
    startChildren()
  }

  func startOnboardingFlow() {
    let onboardingCoordinator = OnboardingCoordinator(window: window, dependencies: dependencies)
    onboardingCoordinator.delegate = self
    addChildCoordinator(onboardingCoordinator)
    startChildren()
  }
}

extension AppCoordinator: MainFlowCoordinatorDelegate {
  func mainFlowCoordinatorDidChangeUsername(_ coordinator: MainFlowCoordinator) {
    start()
  }
}

extension AppCoordinator: OnboardingCoordinatorDelegate {
  func onboardingCoordinatorDidFinish(_ coordinator: OnboardingCoordinator) {
    start()
  }
}
