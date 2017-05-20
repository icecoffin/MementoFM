//
//  ArtistCoordinator.swift
//  LastFMNotifier
//
//  Created by Daniel on 19/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

class ArtistCoordinator: NavigationFlowCoordinator {
  let navigationController: NavigationController
  var childCoordinators: [Coordinator] = []

  fileprivate let artist: Artist
  fileprivate let dependencies: AppDependency

  init(artist: Artist, navigationController: NavigationController, dependencies: AppDependency) {
    self.navigationController = navigationController
    self.artist = artist
    self.dependencies = dependencies
  }

  func start() {
    let viewModel = ArtistViewModel(artist: artist, dependencies: dependencies)
    let dataSource = ArtistDataSource(viewModel: viewModel)

    let viewController = ArtistViewController(dataSource: dataSource)
    viewController.title = viewModel.title
    viewController.navigationItem.leftBarButtonItem = makeBackButton()
    viewController.hidesBottomBarWhenPushed = true

    navigationController.pushViewController(viewController, animated: true)
  }
}
