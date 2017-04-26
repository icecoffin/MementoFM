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
  private let realmGateway: RealmGateway
  private let networkService: NetworkService

  weak var delegate: MainFlowCoordinatorDelegate?

  init(window: UIWindow, realmGateway: RealmGateway, networkService: NetworkService) {
    self.window = window
    self.realmGateway = realmGateway
    self.networkService = networkService
  }

  func start() {
    AppearanceConfigurator.configureAppearance()

    let tabBarController = UITabBarController()
    tabBarController.tabBar.isTranslucent = false

    let libraryNavigationController = UINavigationController()
    let libraryTabBarItem = UITabBarItem(title: "Library".unlocalized,
                                         image: #imageLiteral(resourceName: "icon_library"),
                                         selectedImage: nil)
    libraryNavigationController.tabBarItem = libraryTabBarItem
    let libraryCoordinator = LibraryCoordinator(navigationController: libraryNavigationController,
                                                realmGateway: realmGateway,
                                                networkService: networkService)
    addChildCoordinator(libraryCoordinator)

    let settingsNavigationController = UINavigationController()
    let settingsTabBarItem = UITabBarItem(title: "Settings".unlocalized,
                                          image: #imageLiteral(resourceName: "icon_settings"),
                                          selectedImage: nil)
    settingsNavigationController.tabBarItem = settingsTabBarItem
    let settingsCoordinator = SettingsCoordinator(navigationController: settingsNavigationController, realmGateway: realmGateway)
    settingsCoordinator.delegate = self
    addChildCoordinator(settingsCoordinator)

    tabBarController.viewControllers = [libraryNavigationController, settingsNavigationController]
    window.rootViewController = tabBarController
    window.makeKeyAndVisible()

    startChildren()
  }
}

extension MainFlowCoordinator: SettingsCoordinatorDelegate {
  func settingsCoordinatorDidChangeUsername(_ coordinator: SettingsCoordinator) {
    delegate?.mainFlowCoordinatorDidChangeUsername(self)
  }
}
