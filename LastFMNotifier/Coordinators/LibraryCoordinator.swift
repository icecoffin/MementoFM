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
  fileprivate let realmGateway: RealmGateway

  init(navigationController: UINavigationController, realmGateway: RealmGateway) {
    self.navigationController = navigationController
    self.realmGateway = realmGateway
  }

  func start() {
    let libraryViewModel = LibraryViewModel(realmGateway: realmGateway)
    libraryViewModel.delegate = self
    let libraryViewController = LibraryViewController(viewModel: libraryViewModel)
    navigationController.pushViewController(libraryViewController, animated: false)
  }
}

extension LibraryCoordinator: LibraryViewModelDelegate {
  func libraryViewModel(_ viewModel: LibraryViewModel, didSelectArtist artist: Artist) {
    let artistViewModel = ArtistViewModel(artist: artist, realmGateway: realmGateway)

    let artistViewController = ArtistViewController(viewModel: artistViewModel)
    artistViewController.navigationItem.leftBarButtonItem = createBackButton()
    artistViewController.hidesBottomBarWhenPushed = true

    navigationController.pushViewController(artistViewController, animated: true)
  }
}
