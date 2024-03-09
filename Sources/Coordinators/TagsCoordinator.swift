//
//  TagsCoordinator.swift
//  MementoFM
//
//  Created by Daniel on 16/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

final class TagsCoordinator: NavigationFlowCoordinator {
    var childCoordinators: [Coordinator] = []
    var didFinish: (() -> Void)?

    let navigationController: UINavigationController
    private let dependencies: AppDependency
    private let popTracker: NavigationControllerPopTracker

    init(
        navigationController: UINavigationController,
        popTracker: NavigationControllerPopTracker,
        dependencies: AppDependency
    ) {
        self.navigationController = navigationController
        self.popTracker = popTracker
        self.dependencies = dependencies
    }

    func start() {
        let viewModel = TagsViewModel(dependencies: dependencies)
        viewModel.delegate = self
        let searchController = UISearchController(searchResultsController: nil)
        let viewController = TagsViewController(searchController: searchController, viewModel: viewModel)
        viewController.title = "Tags".unlocalized
        viewController.navigationItem.backButtonDisplayMode = .minimal
        viewController.navigationItem.searchController = searchController
        viewController.navigationItem.hidesSearchBarWhenScrolling = false
        navigationController.pushViewController(viewController, animated: false)
    }
}

// MARK: - TagsViewModelDelegate

extension TagsCoordinator: TagsViewModelDelegate {
    func tagsViewModel(_ viewModel: TagsViewModel, didSelectTagWithName name: String) {
        let viewModelFactory = ArtistsByTagViewModelFactory(tagName: name, dependencies: dependencies)
        let artistListCoordinator = ArtistListCoordinator(
            navigationController: navigationController,
            popTracker: popTracker,
            shouldStartAnimated: true,
            viewModelFactory: viewModelFactory,
            dependencies: dependencies
        )
        addChildCoordinator(artistListCoordinator)
        artistListCoordinator.start()
    }
}

// MARK: - ArtistListViewModelDelegate

extension TagsCoordinator: ArtistListViewModelDelegate {
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
