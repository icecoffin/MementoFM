//
//  SettingsCoordinator.swift
//  MementoFM
//
//  Created by Daniel on 16/12/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit
import Core
import Sync
import IgnoredTagsInterface
import EnterUsername

// MARK: - SettingsCoordinatorDelegate

public protocol SettingsCoordinatorDelegate: AnyObject {
    func settingsCoordinatorDidChangeUsername(_ coordinator: SettingsCoordinator)
}

// MARK: - SettingsCoordinator

public final class SettingsCoordinator: NavigationFlowCoordinator {
    // MARK: - Private properties

    private let dependencies: SettingsDependencies

    // MARK: - Public properties

    public var childCoordinators: [Coordinator] = []
    public var didFinish: (() -> Void)?

    public let navigationController: UINavigationController

    public weak var delegate: SettingsCoordinatorDelegate?

    public init(
        navigationController: UINavigationController,
        dependencies: SettingsDependencies
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    public func start() {
        let settingsViewModel = SettingsViewModel()
        settingsViewModel.delegate = self
        let settingsViewController = SettingsViewController(viewModel: settingsViewModel)
        settingsViewController.title = "Settings".unlocalized
        settingsViewController.navigationItem.backButtonDisplayMode = .minimal
        navigationController.pushViewController(settingsViewController, animated: false)
    }
}

// MARK: - SettingsViewModelDelegate

extension SettingsCoordinator: SettingsViewModelDelegate {
    func settingsViewModelDidRequestOpenIgnoredTags(_ viewModel: SettingsViewModel) {
        let ignoredTagsCoordinator = dependencies.ignoredTagsCoordinatorFactory.makeIgnoredCoordinator(
            navigationController: navigationController,
            shouldAddDefaultTags: false,
            showAnimated: true
        )
        addChildCoordinator(ignoredTagsCoordinator)
        ignoredTagsCoordinator.delegate = self
        ignoredTagsCoordinator.start()
    }

    func settingsViewModelDidRequestChangeUser(_ viewModel: SettingsViewModel) {
        let enterUsernameCoordinator = dependencies.enterUsernameCoordinatorFactory.makeEnterUsernameCoordinator(
            navigationController: navigationController,
            configuration: .init(
                title: "Change Username".unlocalized,
                showsBackButtonTitle: true
            )
        )
        enterUsernameCoordinator.delegate = self
        addChildCoordinator(enterUsernameCoordinator)
        enterUsernameCoordinator.start()
    }

    func settingsViewModelDidRequestOpenAbout(_ viewModel: SettingsViewModel) {
        let viewController = AboutViewController()
        viewController.title = "About".unlocalized
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
    }
}

// MARK: - EnterUsernameCoordinatorDelegate

extension SettingsCoordinator: EnterUsernameCoordinatorDelegate {
    public func enterUsernameCoordinatorDidFinish(_ coordinator: EnterUsernameCoordinator) {
        showSync()
    }

    private func showSync() {
        let syncCoordinator = dependencies.syncCoordinatorFactory.makeSyncCoordinator(navigationController: navigationController)
        addChildCoordinator(syncCoordinator)
        syncCoordinator.delegate = self
        syncCoordinator.start()
    }
}

// MARK: - SyncCoordinatorDelegate

extension SettingsCoordinator: SyncCoordinatorDelegate {
    public func syncCoordinatorDidFinishSync(_ coordinator: SyncCoordinator) {
        delegate?.settingsCoordinatorDidChangeUsername(self)
    }
}

// MARK: - IgnoredTagsCoordinatorDelegate

extension SettingsCoordinator: IgnoredTagsCoordinatorDelegate {
    public func ignoredTagsCoordinatorDidSaveChanges(_ coordinator: any IgnoredTagsCoordinatorProtocol) {
        navigationController.popViewController(animated: true)
    }
}
