//
//  LibraryCoordinator.swift
//  LastFMNotifier
//
//  Created by Daniel on 09/12/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit

class LibraryCoordinator: NavigationFlowCoordinator {
  var childCoordinators: [Coordinator] = []

  let navigationController: UINavigationController
  fileprivate let dependencies: AppDependency

  private var onApplicationDidBecomeActive: (() -> Void)?

  init(navigationController: UINavigationController, dependencies: AppDependency) {
    self.navigationController = navigationController
    self.dependencies = dependencies
    subscribeToNotifications()
  }

  deinit {
    unsubscribeFromNotifications()
  }

  func start() {
    let libraryViewModel = LibraryViewModel(dependencies: dependencies)
    libraryViewModel.delegate = self
    onApplicationDidBecomeActive = { [unowned libraryViewModel] in
      libraryViewModel.requestDataIfNeeded()
    }
    let libraryViewController = LibraryViewController(viewModel: libraryViewModel)
    libraryViewController.title = "Library".unlocalized
    navigationController.pushViewController(libraryViewController, animated: false)
  }

  private func subscribeToNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)),
                                           name: .UIApplicationDidBecomeActive, object: nil)
  }

  private func unsubscribeFromNotifications() {
    NotificationCenter.default.removeObserver(self, name: .UIApplicationDidBecomeActive, object: nil)
  }

  @objc private func applicationDidBecomeActive(_ notification: Notification) {
    onApplicationDidBecomeActive?()
  }
}

extension LibraryCoordinator: LibraryViewModelDelegate {
  func libraryViewModel(_ viewModel: LibraryViewModel, didSelectArtist artist: Artist) {
    let artistViewModel = ArtistViewModel(artist: artist, dependencies: dependencies)
    let artistDataSource = ArtistDataSource(viewModel: artistViewModel)

    let artistViewController = ArtistViewController(dataSource: artistDataSource)
    artistViewController.title = artistViewModel.title
    artistViewController.navigationItem.leftBarButtonItem = makeBackButton()
    artistViewController.hidesBottomBarWhenPushed = true

    navigationController.pushViewController(artistViewController, animated: true)
  }
}
