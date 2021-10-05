//
//  SettingsCoordinator.swift
//  MementoFM
//
//  Created by Daniel on 16/12/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit

// MARK: - SettingsCoordinatorDelegate

protocol SettingsCoordinatorDelegate: AnyObject {
    func settingsCoordinatorDidChangeUsername(_ coordinator: SettingsCoordinator)
}

// MARK: - SettingsCoordinator

final class SettingsCoordinator: NavigationFlowCoordinator, IgnoredTagsPresenter, SyncPresenter {
    var childCoordinators: [Coordinator] = []
    var didFinish: (() -> Void)?

    let navigationController: UINavigationController
    let dependencies: AppDependency

    weak var delegate: SettingsCoordinatorDelegate?

    init(navigationController: UINavigationController, dependencies: AppDependency) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    func start() {
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
        let viewController = makeIgnoredTagsViewController(dependencies: dependencies, shouldAddDefaultTags: false)
        navigationController.pushViewController(viewController, animated: true)
    }

    func settingsViewModelDidRequestChangeUser(_ viewModel: SettingsViewModel) {
        let viewModel = EnterUsernameViewModel(dependencies: dependencies)
        viewModel.delegate = self
        let viewController = EnterUsernameViewController(viewModel: viewModel)
        viewController.title = "Change Username".unlocalized
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
    }

    func settingsViewModelDidRequestOpenAbout(_ viewModel: SettingsViewModel) {
        let viewController = AboutViewController()
        viewController.title = "About".unlocalized
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
    }
}

// MARK: - EnterUsernameViewModelDelegate

extension SettingsCoordinator: EnterUsernameViewModelDelegate {
    func enterUsernameViewModelDidFinish(_ viewModel: EnterUsernameViewModel) {
        showSyncViewController()
    }

    func showSyncViewController() {
        let syncViewController = makeSyncViewController(dependencies: dependencies)
        syncViewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(syncViewController, animated: true)
        navigationController.interactivePopGestureRecognizer?.isEnabled = false
        navigationController.setNavigationBarHidden(true, animated: false)
    }
}

// MARK: - IgnoredTagsViewModelDelegate

extension SettingsCoordinator: IgnoredTagsViewModelDelegate {
    func ignoredTagsViewModelDidSaveChanges(_ viewModel: IgnoredTagsViewModel) {
        navigationController.popViewController(animated: true)
    }
}

// MARK: - SyncViewModelDelegate

extension SettingsCoordinator: SyncViewModelDelegate {
    func syncViewModelDidFinishLoading(_ viewModel: SyncViewModel) {
        delegate?.settingsCoordinatorDidChangeUsername(self)
    }
}
