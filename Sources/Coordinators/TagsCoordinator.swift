//
//  TagsCoordinator.swift
//  LastFMNotifier
//
//  Created by Daniel on 16/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

class TagsCoordinator: NavigationFlowCoordinator, ArtistPresenter {
  var childCoordinators: [Coordinator] = []

  let navigationController: UINavigationController
  fileprivate let dependencies: AppDependency

  init(navigationController: UINavigationController, dependencies: AppDependency) {
    self.navigationController = navigationController
    self.dependencies = dependencies
  }

  func start() {
    let viewModel = TagsViewModel(dependencies: dependencies)
    viewModel.delegate = self
    let viewController = TagsViewController(viewModel: viewModel)
    viewController.title = "Tags".unlocalized
    navigationController.pushViewController(viewController, animated: false)
  }
}

extension TagsCoordinator: TagsViewModelDelegate {
  func tagsViewModel(_ viewModel: TagsViewModel, didSelectTagWithName name: String) {
    let viewModel = ArtistsByTagViewModel(tagName: name, dependencies: dependencies)
    viewModel.delegate = self
    let viewController = LibraryViewController(viewModel: viewModel)
    viewController.navigationItem.leftBarButtonItem = makeBackButton()
    viewController.title = name
    navigationController.pushViewController(viewController, animated: true)
  }
}

extension TagsCoordinator: LibraryViewModelDelegate {
  func libraryViewModel(_ viewModel: LibraryViewModelProtocol, didSelectArtist artist: Artist) {
    let artistViewController = makeArtistViewController(for: artist, dependencies: dependencies)
    navigationController.pushViewController(artistViewController, animated: true)
  }
}
