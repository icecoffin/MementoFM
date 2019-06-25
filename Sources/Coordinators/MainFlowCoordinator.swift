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

final class MainFlowCoordinator: Coordinator {
  var childCoordinators: [Coordinator] = []
  var didFinish: (() -> Void)?

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
    let libraryCoordinator = makeLibraryCoordinator(with: libraryNavigationController)
    addChildCoordinator(libraryCoordinator)

    let tagsNavigationController = NavigationController()
    let tagsCoordinator = makeTagsCoordinator(with: tagsNavigationController)
    addChildCoordinator(tagsCoordinator)

    let settingsNavigationController = NavigationController()
    let settingsCoordinator = makeSettingsCoordinator(with: settingsNavigationController)
    addChildCoordinator(settingsCoordinator)

    tabBarController.viewControllers = [libraryNavigationController, tagsNavigationController, settingsNavigationController]

    if window.rootViewController != nil {
      UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: {
        self.window.rootViewController = tabBarController
      })
    } else {
      window.rootViewController = tabBarController
    }
    window.makeKeyAndVisible()

    startChildren()
  }

  private func makeLibraryCoordinator(with navigationController: NavigationController) -> ArtistListCoordinator {
    let popTracker = NavigationControllerPopTracker(navigationController: navigationController)
    let tabBarItem = UITabBarItem(title: "Library".unlocalized, image: .tabBarLibrary, selectedImage: nil)
    navigationController.tabBarItem = tabBarItem
    return ArtistListCoordinator(navigationController: navigationController,
                                 popTracker: popTracker,
                                 configuration: LibraryCoordinatorConfiguration(),
                                 viewModelFactory: LibraryViewModelFactory(dependencies: dependencies),
                                 dependencies: dependencies)

  }

  private func makeTagsCoordinator(with navigationController: NavigationController) -> TagsCoordinator {
    let popTracker = NavigationControllerPopTracker(navigationController: navigationController)
    let tabBarItem = UITabBarItem(title: "Tags".unlocalized, image: .tabBarTags, selectedImage: nil)
    navigationController.tabBarItem = tabBarItem
    return TagsCoordinator(navigationController: navigationController,
                           popTracker: popTracker,
                           dependencies: dependencies)
  }

  private func makeSettingsCoordinator(with navigationController: NavigationController) -> SettingsCoordinator {
    let tabBarItem = UITabBarItem(title: "Settings".unlocalized, image: .tabBarSettings, selectedImage: nil)
    navigationController.tabBarItem = tabBarItem
    let settingsCoordinator = SettingsCoordinator(navigationController: navigationController,
                                                  dependencies: dependencies)
    settingsCoordinator.delegate = self

    return settingsCoordinator
  }
}

extension MainFlowCoordinator: SettingsCoordinatorDelegate {
  func settingsCoordinatorDidChangeUsername(_ coordinator: SettingsCoordinator) {
    delegate?.mainFlowCoordinatorDidChangeUsername(self)
  }
}
