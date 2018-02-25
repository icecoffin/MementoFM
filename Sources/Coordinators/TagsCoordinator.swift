//
//  TagsCoordinator.swift
//  MementoFM
//
//  Created by Daniel on 16/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

class TagsCoordinator: NSObject, NavigationFlowCoordinator, ArtistsByTagPresenter {
  var childCoordinators: [Coordinator] = []
  var onDidFinish: (() -> Void)?

  let navigationController: NavigationController
  private let dependencies: AppDependency
  private let popTracker: NavigationControllerPopTracker

  init(navigationController: NavigationController,
       popTracker: NavigationControllerPopTracker,
       dependencies: AppDependency) {
    self.navigationController = navigationController
    self.popTracker = popTracker
    self.dependencies = dependencies
    super.init()
  }

  func start() {
    let viewModel = TagsViewModel(dependencies: dependencies)
    viewModel.delegate = self
    let searchController = UISearchController(searchResultsController: nil)
    let viewController = TagsViewController(searchController: searchController, viewModel: viewModel)
    viewController.title = "Tags".unlocalized
    viewController.navigationItem.searchController = searchController
    viewController.navigationItem.hidesSearchBarWhenScrolling = false
    navigationController.pushViewController(viewController, animated: false)
  }
}

extension TagsCoordinator: TagsViewModelDelegate {
  func tagsViewModel(_ viewModel: TagsViewModel, didSelectTagWithName name: String) {
    let viewModelFactory = ArtistsByTagViewModelFactory(tagName: name, dependencies: dependencies)
    let artistListCoordinator = ArtistListCoordinator(navigationController: navigationController,
                                                      popTracker: popTracker,
                                                      configuration: ArtistsByTagCoordinatorConfiguration(),
                                                      viewModelFactory: viewModelFactory,
                                                      dependencies: dependencies)
    addChildCoordinator(artistListCoordinator)
    artistListCoordinator.start()
  }
}

extension TagsCoordinator: ArtistListViewModelDelegate {
  func artistListViewModel(_ viewModel: ArtistListViewModel, didSelectArtist artist: Artist) {
    let artistCoordinator = ArtistCoordinator(artist: artist,
                                              navigationController: navigationController,
                                              popTracker: popTracker,
                                              dependencies: dependencies)
    addChildCoordinator(artistCoordinator)
    artistCoordinator.start()
  }
}
