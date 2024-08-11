//
//  SettingsFlowController.swift
//  MementoFM
//
//  Created by Dani on 11.08.2024.
//  Copyright © 2024 icecoffin. All rights reserved.
//

import UIKit

// MARK: - SettingsFlowControllerDelegate

protocol SettingsFlowControllerDelegate: AnyObject {
    func settingsFlowControllerDidChangeUsername(_ flowController: SettingsFlowController)
}

// MARK: - SettingsFlowController

final class SettingsFlowController: UIViewController, FlowController, IgnoredTagsPresenter, SyncPresenter {
    private let dependencies: AppDependency

    weak var delegate: SettingsFlowControllerDelegate?

    init(dependencies: AppDependency) {
        self.dependencies = dependencies
        super.init(nibName: nil, bundle: nil)

        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        title = "Settings".unlocalized
        navigationItem.backButtonDisplayMode = .minimal

        let settingsViewModel = SettingsViewModel()
        settingsViewModel.delegate = self

        let settingsViewController = SettingsViewController(viewModel: settingsViewModel)
        add(child: settingsViewController)
    }
}

// MARK: - SettingsViewModelDelegate

extension SettingsFlowController: SettingsViewModelDelegate {
    func settingsViewModelDidRequestOpenIgnoredTags(_ viewModel: SettingsViewModel) {
        let viewController = makeIgnoredTagsViewController(dependencies: dependencies, shouldAddDefaultTags: false)
        navigationController?.pushViewController(viewController, animated: true)
    }

    func settingsViewModelDidRequestChangeUser(_ viewModel: SettingsViewModel) {
        let viewModel = EnterUsernameViewModel(dependencies: dependencies)
        viewModel.delegate = self
        let viewController = EnterUsernameViewController(viewModel: viewModel)
        viewController.title = "Change Username".unlocalized
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }

    func settingsViewModelDidRequestOpenAbout(_ viewModel: SettingsViewModel) {
        let viewController = AboutViewController()
        viewController.title = "About".unlocalized
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - EnterUsernameViewModelDelegate

extension SettingsFlowController: EnterUsernameViewModelDelegate {
    func enterUsernameViewModelDidFinish(_ viewModel: EnterUsernameViewModel) {
        showSyncViewController()
    }

    func showSyncViewController() {
        let syncViewController = makeSyncViewController(dependencies: dependencies)
        syncViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(syncViewController, animated: true)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

// MARK: - IgnoredTagsViewModelDelegate

extension SettingsFlowController: IgnoredTagsViewModelDelegate {
    func ignoredTagsViewModelDidSaveChanges(_ viewModel: IgnoredTagsViewModel) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - SyncViewModelDelegate

extension SettingsFlowController: SyncViewModelDelegate {
    func syncViewModelDidFinishLoading(_ viewModel: SyncViewModel) {
        delegate?.settingsFlowControllerDidChangeUsername(self)
    }
}
