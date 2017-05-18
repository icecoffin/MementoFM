//
//  TagsCoordinator.swift
//  LastFMNotifier
//
//  Created by Daniel on 16/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

class TagsCoordinator: Coordinator {
  var childCoordinators: [Coordinator] = []

  let navigationController: UINavigationController
  fileprivate let dependencies: AppDependency

  init(navigationController: UINavigationController, dependencies: AppDependency) {
    self.navigationController = navigationController
    self.dependencies = dependencies
  }

  func start() {
    let tagsViewModel = TagsViewModel(dependencies: dependencies)
    let tagsViewController = TagsViewController(viewModel: tagsViewModel)
    tagsViewController.title = "Tags".unlocalized
    navigationController.pushViewController(tagsViewController, animated: false)
  }
}
