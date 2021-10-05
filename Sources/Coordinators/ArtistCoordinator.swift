//
//  ArtistCoordinator.swift
//  MementoFM
//
//  Created by Daniel on 19/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

final class ArtistCoordinator: NavigationFlowCoordinator, NavigationControllerPopObserver {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var didFinish: (() -> Void)?

    private let artist: Artist
    private let popTracker: NavigationControllerPopTracker
    private let dependencies: AppDependency

    init(artist: Artist,
         navigationController: UINavigationController,
         popTracker: NavigationControllerPopTracker,
         dependencies: AppDependency) {
        self.artist = artist
        self.navigationController = navigationController
        self.popTracker = popTracker
        self.dependencies = dependencies
    }

    func start() {
        let viewModel = ArtistViewModel(artist: artist, dependencies: dependencies)
        viewModel.delegate = self
        let dataSource = ArtistDataSource(viewModel: viewModel)

        let viewController = ArtistViewController(dataSource: dataSource)
        viewController.title = viewModel.title
        viewController.navigationItem.backButtonDisplayMode = .minimal
        viewController.hidesBottomBarWhenPushed = true

        popTracker.addObserver(self, forPopTransitionOf: viewController)

        navigationController.pushViewController(viewController, animated: true)
    }
}

// MARK: - ArtistViewModelDelegate

extension ArtistCoordinator: ArtistViewModelDelegate {
    func artistViewModel(_ viewModel: ArtistViewModel, didSelectTagWithName name: String) {
        let viewModelFactory = ArtistsByTagViewModelFactory(tagName: name, dependencies: dependencies)
        let artistListCoordinator = ArtistListCoordinator(navigationController: navigationController,
                                                          popTracker: popTracker,
                                                          shouldStartAnimated: true,
                                                          viewModelFactory: viewModelFactory,
                                                          dependencies: dependencies)
        addChildCoordinator(artistListCoordinator)
        artistListCoordinator.start()
    }

    func artistViewModel(_ viewModel: ArtistViewModel, didSelectArtist artist: Artist) {
        let artistCoordinator = ArtistCoordinator(artist: artist,
                                                  navigationController: navigationController,
                                                  popTracker: popTracker,
                                                  dependencies: dependencies)
        addChildCoordinator(artistCoordinator)
        artistCoordinator.start()
    }
}
