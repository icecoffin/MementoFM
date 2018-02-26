//
//  MainFlowCoordinator.swift
//  MementoFM
//
//  Created by Daniel on 09/12/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit

protocol MainFlowCoordinatorDelegate: class {
  func mainFlowCoordinatorDidChangeUsername(_ coordinator: MainFlowCoordinator)
}

class MainFlowCoordinator: Coordinator {
  var childCoordinators: [Coordinator] = []
  var onDidFinish: (() -> Void)?

  private let window: UIWindow
  private let dependencies: AppDependency

  weak var delegate: MainFlowCoordinatorDelegate?

  init(window: UIWindow, dependencies: AppDependency) {
    self.window = window
    self.dependencies = dependencies
  }

  func start() {
    AppearanceConfigurator.configureAppearance()

    let tabBarController = UITabBarController()
    tabBarController.tabBar.isTranslucent = false

    let libraryNavigationController = NavigationController()
    let libraryPopTracker = NavigationControllerPopTracker(navigationController: libraryNavigationController)
    let libraryTabBarItem = UITabBarItem(title: "Library".unlocalized, image: R.image.iconLibrary(), selectedImage: nil)
    libraryNavigationController.tabBarItem = libraryTabBarItem
    let libraryCoordinator = ArtistListCoordinator(navigationController: libraryNavigationController,
                                                   popTracker: libraryPopTracker,
                                                   configuration: LibraryCoordinatorConfiguration(),
                                                   viewModelFactory: LibraryViewModelFactory(dependencies: dependencies),
                                                   dependencies: dependencies)
    addChildCoordinator(libraryCoordinator)

    let tagsNavigationController = NavigationController()
    let tagsPopTracker = NavigationControllerPopTracker(navigationController: tagsNavigationController)
    let tagsTabBarItem = UITabBarItem(title: "Tags".unlocalized, image: R.image.iconTag(), selectedImage: nil)
    tagsNavigationController.tabBarItem = tagsTabBarItem
    let tagsCoordinator = TagsCoordinator(navigationController: tagsNavigationController,
                                          popTracker: tagsPopTracker,
                                          dependencies: dependencies)
    addChildCoordinator(tagsCoordinator)

    let settingsNavigationController = NavigationController()
    let settingsTabBarItem = UITabBarItem(title: "Settings".unlocalized, image: R.image.iconSettings(), selectedImage: nil)
    settingsNavigationController.tabBarItem = settingsTabBarItem
    let settingsCoordinator = SettingsCoordinator(navigationController: settingsNavigationController, dependencies: dependencies)
    settingsCoordinator.delegate = self
    addChildCoordinator(settingsCoordinator)

    tabBarController.viewControllers = [libraryNavigationController, tagsNavigationController, settingsNavigationController]

    if let currentRootView = window.rootViewController?.view {
      UIView.transition(from: currentRootView, to: tabBarController.view, duration: 0.5,
                        options: [.transitionFlipFromRight], completion: { _ in
        self.window.rootViewController = tabBarController
      })
    } else {
      window.rootViewController = tabBarController
    }
    window.makeKeyAndVisible()

    startChildren()
  }
}

extension MainFlowCoordinator: SettingsCoordinatorDelegate {
  func settingsCoordinatorDidChangeUsername(_ coordinator: SettingsCoordinator) {
    delegate?.mainFlowCoordinatorDidChangeUsername(self)
  }
}
