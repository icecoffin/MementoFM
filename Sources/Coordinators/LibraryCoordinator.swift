//
//  LibraryCoordinator.swift
//  LastFMNotifier
//
//  Created by Daniel on 09/12/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit

class LibraryCoordinator: NavigationFlowCoordinator, ArtistPresenter {
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
  func libraryViewModel(_ viewModel: LibraryViewModelProtocol, didSelectArtist artist: Artist) {
    let artistViewController = makeArtistViewController(for: artist, dependencies: dependencies)
    navigationController.pushViewController(artistViewController, animated: true)
  }
}
