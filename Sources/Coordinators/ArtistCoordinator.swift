//
//  ArtistCoordinator.swift
//  LastFMNotifier
//
//  Created by Daniel on 19/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

protocol ArtistCoordinatorDelegate: class {
  func artistCoordinatorDidFinish(_ coordinator: ArtistCoordinator)
}

class ArtistCoordinator: NavigationFlowCoordinator {
  let navigationController: UINavigationController
  var childCoordinators: [Coordinator] = []

  weak var delegate: ArtistCoordinatorDelegate?

  fileprivate let artist: Artist
  fileprivate let dependencies: AppDependency

  init(artist: Artist, navigationController: UINavigationController, dependencies: AppDependency) {
    self.navigationController = navigationController
    self.artist = artist
    self.dependencies = dependencies
  }

  func start() {
    let viewModel = ArtistViewModel(artist: artist, dependencies: dependencies)
    let dataSource = ArtistDataSource(viewModel: viewModel)

    let viewController = ArtistViewController(dataSource: dataSource)
    viewController.title = viewModel.title
    viewController.navigationItem.leftBarButtonItem = makeBackButton(tapHandler: { [unowned self] in
      self.delegate?.artistCoordinatorDidFinish(self)
    })
    viewController.hidesBottomBarWhenPushed = true

    navigationController.pushViewController(viewController, animated: true)
  }
}
