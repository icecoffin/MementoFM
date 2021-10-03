//
//  AppCoordinator.swift
//  MementoFM
//
//  Created by Daniel on 16/11/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit

// MARK: - AppCoordinator

final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var didFinish: (() -> Void)?

    private let window: UIWindow
    private let dependencies: AppDependency

    init(window: UIWindow, dependencies: AppDependency = AppDependency.default) {
        self.window = window
        self.dependencies = dependencies
    }

    func start() {
        removeAllChildren()

        if dependencies.userService.didFinishOnboarding {
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

// MARK: - MainFlowCoordinatorDelegate

extension AppCoordinator: MainFlowCoordinatorDelegate {
    func mainFlowCoordinatorDidChangeUsername(_ coordinator: MainFlowCoordinator) {
        start()
    }
}

// MARK: - OnboardingCoordinatorDelegate

extension AppCoordinator: OnboardingCoordinatorDelegate {
    func onboardingCoordinatorDidFinish(_ coordinator: OnboardingCoordinator) {
        start()
    }
}
