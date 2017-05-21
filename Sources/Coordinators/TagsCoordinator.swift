//
//  TagsCoordinator.swift
//  MementoFM
//
//  Created by Daniel on 16/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

class TagsCoordinator: NSObject, NavigationFlowCoordinator {
  var childCoordinators: [Coordinator] = []

  let navigationController: NavigationController
  fileprivate let dependencies: AppDependency

  init(navigationController: NavigationController, dependencies: AppDependency) {
    self.navigationController = navigationController
    self.dependencies = dependencies
    super.init()
    navigationController.delegate = self
    navigationController.interactivePopGestureRecognizer?.delegate = nil
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
    let artistCoordinator = ArtistCoordinator(artist: artist,
                                              navigationController: navigationController,
                                              dependencies: dependencies)
    addChildCoordinator(artistCoordinator)
    artistCoordinator.start()
  }
}

extension TagsCoordinator: UINavigationControllerDelegate {
  func navigationController(_ navigationController: UINavigationController,
                            didShow viewController: UIViewController,
                            animated: Bool) {

    guard let poppingViewController = navigationController.poppingViewController() else {
      return
    }

    if poppingViewController is ArtistViewController {
      childCoordinators.removeLast()
    }
  }
}
