//
//  MainFlowCoordinator.swift
//  LastFMNotifier
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

  private let window: UIWindow
  fileprivate let dependencies: AppDependency

  weak var delegate: MainFlowCoordinatorDelegate?

  init(window: UIWindow, dependencies: AppDependency) {
    self.window = window
    self.dependencies = dependencies
  }

  func start() {
    AppearanceConfigurator.configureAppearance()

    let tabBarController = UITabBarController()
    tabBarController.tabBar.isTranslucent = false

    let libraryNavigationController = UINavigationController()
    let libraryTabBarItem = UITabBarItem(title: "Library".unlocalized, image: #imageLiteral(resourceName: "icon_library"), selectedImage: nil)
    libraryNavigationController.tabBarItem = libraryTabBarItem
    let libraryCoordinator = LibraryCoordinator(navigationController: libraryNavigationController, dependencies: dependencies)
    addChildCoordinator(libraryCoordinator)

    let tagsNavigationController = UINavigationController()
    let tagsTabBarItem = UITabBarItem(title: "Tags".unlocalized, image: #imageLiteral(resourceName: "icon_tag"), selectedImage: nil)
    tagsNavigationController.tabBarItem = tagsTabBarItem
    let tagsCoordinator = TagsCoordinator(navigationController: tagsNavigationController, dependencies: dependencies)
    addChildCoordinator(tagsCoordinator)

    let settingsNavigationController = UINavigationController()
    let settingsTabBarItem = UITabBarItem(title: "Settings".unlocalized, image: #imageLiteral(resourceName: "icon_settings"), selectedImage: nil)
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