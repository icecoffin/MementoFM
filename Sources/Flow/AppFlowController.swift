//
//  AppFlowController.swift
//  MementoFM
//
//  Created by Daniel on 16/11/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit

final class AppFlowController {
    private let window: UIWindow
    private let dependencies: AppDependency

    init(window: UIWindow, dependencies: AppDependency = .default) {
        self.window = window
        self.dependencies = dependencies
    }

    func start() {
        if dependencies.userService.didFinishOnboarding {
            startMainFlow()
        } else {
            startOnboardingFlow()
        }
        window.makeKeyAndVisible()
    }

    private func startMainFlow() {
        let mainFlowController = MainFlowController(dependencies: dependencies)
        mainFlowController.delegate = self

        if window.rootViewController != nil {
            UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: {
                self.window.rootViewController = mainFlowController
            })
        } else {
            window.rootViewController = mainFlowController
        }
    }

    private func startOnboardingFlow() {
        let onboardingFlowController = OnboardingFlowController(dependencies: dependencies)
        onboardingFlowController.delegate = self
        window.rootViewController = onboardingFlowController
    }
}

// MARK: - MainFlowControllerDelegate

extension AppFlowController: MainFlowControllerDelegate {
    func mainFlowControllerDidChangeUsername(_ flowController: MainFlowController) {
        start()
    }
}

// MARK: - OnboardingFlowControllerDelegate

extension AppFlowController: OnboardingFlowControllerDelegate {
    func onboardingFlowControllerDidFinish(_ flowController: OnboardingFlowController) {
        start()
    }
}
