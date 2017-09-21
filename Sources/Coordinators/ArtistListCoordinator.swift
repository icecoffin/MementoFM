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
  fileprivate let popTracker: NavigationControllerPopTracker
  fileprivate let configuration: ArtistListCoordinatorConfiguration
  fileprivate let viewModelFactory: ArtistListViewModelFactory
  fileprivate let dependencies: AppDependency

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
    popTracker.addDelegate(self)

    let artistListViewModel = viewModelFactory.makeViewModel()
    artistListViewModel.delegate = self
    let searchController = UISearchController(searchResultsController: nil)
    let artistListViewController = ArtistListViewController(searchController: searchController, viewModel: artistListViewModel)
    artistListViewController.navigationItem.leftBarButtonItem = configuration.backButtonItem(for: self)
    artistListViewController.navigationItem.searchController = searchController
    artistListViewController.navigationItem.hidesSearchBarWhenScrolling = false
    artistListViewController.title = artistListViewModel.title
    navigationController.pushViewController(artistListViewController, animated: configuration.shouldStartAnimated)
  }

  private func unsubscribeFromNotifications() {
    NotificationCenter.default.removeObserver(self, name: .UIApplicationDidBecomeActive, object: nil)
  }

  func shouldFinishAfterPopping(viewController: UIViewController) -> Bool {
    return viewController is ArtistListViewController
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
