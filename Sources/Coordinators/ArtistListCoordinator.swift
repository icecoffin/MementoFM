//
//  ArtistListCoordinator.swift
//  MementoFM
//
//  Created by Daniel on 09/12/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit

final class ArtistListCoordinator: NavigationFlowCoordinator {
    var childCoordinators: [Coordinator] = []
    var didFinish: (() -> Void)?

    let navigationController: UINavigationController
    private let popTracker: NavigationControllerPopTracker
    private let shouldStartAnimated: Bool
    private let viewModelFactory: ArtistListViewModelFactory
    private let dependencies: AppDependency

    init(
        navigationController: UINavigationController,
        popTracker: NavigationControllerPopTracker,
        shouldStartAnimated: Bool,
        viewModelFactory: ArtistListViewModelFactory,
        dependencies: AppDependency
    ) {
        self.navigationController = navigationController
        self.popTracker = popTracker
        self.shouldStartAnimated = shouldStartAnimated
        self.viewModelFactory = viewModelFactory
        self.dependencies = dependencies
    }

    deinit {
        unsubscribeFromNotifications()
    }

    func start() {
        let viewModel = viewModelFactory.makeViewModel()
        viewModel.delegate = self

        let searchController = UISearchController(searchResultsController: nil)
        let viewController = ArtistListViewController(searchController: searchController, viewModel: viewModel)
        viewController.navigationItem.backButtonDisplayMode = .minimal
        viewController.navigationItem.searchController = searchController
        viewController.navigationItem.hidesSearchBarWhenScrolling = false
        viewController.title = viewModel.title

        popTracker.addObserver(self, forPopTransitionOf: viewController)

        navigationController.pushViewController(viewController, animated: shouldStartAnimated)
    }

    private func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
}

// MARK: - ArtistListViewModelDelegate

extension ArtistListCoordinator: ArtistListViewModelDelegate {
    func artistListViewModel(_ viewModel: ArtistListViewModel, didSelectArtist artist: Artist) {
        let artistCoordinator = ArtistCoordinator(
            artist: artist,
            navigationController: navigationController,
            popTracker: popTracker,
            dependencies: dependencies
        )
        addChildCoordinator(artistCoordinator)
        artistCoordinator.start()
    }
}
