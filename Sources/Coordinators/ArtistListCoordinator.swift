//
//  ArtistListCoordinator.swift
//  MementoFM
//
//  Created by Daniel on 09/12/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit

protocol ArtistListCoordinatorConfiguration {
  var shouldStartAnimated: Bool { get }
  func backButtonItem(for coordinator: NavigationFlowCoordinator) -> UIBarButtonItem?
}

class LibraryCoordinatorConfiguration: ArtistListCoordinatorConfiguration {
  var shouldStartAnimated: Bool {
    return false
  }

  func backButtonItem(for coordinator: NavigationFlowCoordinator) -> UIBarButtonItem? {
    return nil
  }
}

class ArtistsByTagCoordinatorConfiguration: ArtistListCoordinatorConfiguration {
  var shouldStartAnimated: Bool {
    return true
  }

  func backButtonItem(for coordinator: NavigationFlowCoordinator) -> UIBarButtonItem? {
    return coordinator.makeBackButton()
  }
}

class ArtistListCoordinator: NSObject, NavigationFlowCoordinator {
  var childCoordinators: [Coordinator] = []
  var onDidFinish: (() -> Void)?

  let navigationController: NavigationController
  private let popTracker: NavigationControllerPopTracker
  private let configuration: ArtistListCoordinatorConfiguration
  private let viewModelFactory: ArtistListViewModelFactory
  private let dependencies: AppDependency

  init(navigationController: NavigationController,
       popTracker: NavigationControllerPopTracker,
       configuration: ArtistListCoordinatorConfiguration,
       viewModelFactory: ArtistListViewModelFactory,
       dependencies: AppDependency) {
    self.navigationController = navigationController
    self.popTracker = popTracker
    self.configuration = configuration
    self.viewModelFactory = viewModelFactory
    self.dependencies = dependencies
    super.init()
  }

  deinit {
    unsubscribeFromNotifications()
  }

  func start() {
    let viewModel = viewModelFactory.makeViewModel()
    viewModel.delegate = self

    let searchController = UISearchController(searchResultsController: nil)
    let viewController = ArtistListViewController(searchController: searchController, viewModel: viewModel)
    viewController.navigationItem.leftBarButtonItem = configuration.backButtonItem(for: self)
    viewController.navigationItem.searchController = searchController
    viewController.navigationItem.hidesSearchBarWhenScrolling = false
    viewController.title = viewModel.title

    popTracker.addObserver(self, forPopTransitionOf: viewController)

    navigationController.pushViewController(viewController, animated: configuration.shouldStartAnimated)
  }

  private func unsubscribeFromNotifications() {
    NotificationCenter.default.removeObserver(self, name: .UIApplicationDidBecomeActive, object: nil)
  }
}

extension ArtistListCoordinator: ArtistListViewModelDelegate {
  func artistListViewModel(_ viewModel: ArtistListViewModel, didSelectArtist artist: Artist) {
    let artistCoordinator = ArtistCoordinator(artist: artist,
                                              navigationController: navigationController,
                                              popTracker: popTracker,
                                              dependencies: dependencies)
    addChildCoordinator(artistCoordinator)
    artistCoordinator.start()
  }
}
