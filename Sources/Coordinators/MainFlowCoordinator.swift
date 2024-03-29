//
//  MainFlowCoordinator.swift
//  MementoFM
//
//  Created by Daniel on 09/12/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit

// MARK: - MainFlowCoordinatorDelegate

protocol MainFlowCoordinatorDelegate: AnyObject {
    func mainFlowCoordinatorDidChangeUsername(_ coordinator: MainFlowCoordinator)
}

// MARK: - MainFlowCoordinator

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

        let libraryNavigationController = UINavigationController()
        libraryNavigationController.navigationBar.prefersLargeTitles = true
        let libraryCoordinator = makeLibraryCoordinator(with: libraryNavigationController)
        addChildCoordinator(libraryCoordinator)

        let tagsNavigationController = UINavigationController()
        tagsNavigationController.navigationBar.prefersLargeTitles = true
        let tagsCoordinator = makeTagsCoordinator(with: tagsNavigationController)
        addChildCoordinator(tagsCoordinator)

        let countriesNavigationController = UINavigationController()
        countriesNavigationController.navigationBar.prefersLargeTitles = true
        let countriesCoordinator = makeCountriesCoordinator(with: countriesNavigationController)
        addChildCoordinator(countriesCoordinator)

        let settingsNavigationController = UINavigationController()
        settingsNavigationController.navigationBar.prefersLargeTitles = true
        let settingsCoordinator = makeSettingsCoordinator(with: settingsNavigationController)
        addChildCoordinator(settingsCoordinator)

        tabBarController.viewControllers = [libraryNavigationController,
                                            tagsNavigationController,
                                            countriesNavigationController,
                                            settingsNavigationController]

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

    private func makeLibraryCoordinator(with navigationController: UINavigationController) -> ArtistListCoordinator {
        let popTracker = NavigationControllerPopTracker(navigationController: navigationController)
        let tabBarItem = UITabBarItem(title: "Library".unlocalized, image: .tabBarLibrary, selectedImage: nil)
        navigationController.tabBarItem = tabBarItem
        return ArtistListCoordinator(
            navigationController: navigationController,
            popTracker: popTracker,
            shouldStartAnimated: false,
            viewModelFactory: LibraryViewModelFactory(dependencies: dependencies),
            dependencies: dependencies
        )

    }

    private func makeTagsCoordinator(with navigationController: UINavigationController) -> TagsCoordinator {
        let popTracker = NavigationControllerPopTracker(navigationController: navigationController)
        let tabBarItem = UITabBarItem(title: "Tags".unlocalized, image: .tabBarTags, selectedImage: nil)
        navigationController.tabBarItem = tabBarItem
        return TagsCoordinator(
            navigationController: navigationController,
            popTracker: popTracker,
            dependencies: dependencies
        )
    }

    private func makeCountriesCoordinator(with navigationController: UINavigationController) -> CountriesCoordinator {
        let popTracker = NavigationControllerPopTracker(navigationController: navigationController)
        let tabBarItem = UITabBarItem(title: "Countries".unlocalized, image: .tabBarCountries, selectedImage: nil)
        navigationController.tabBarItem = tabBarItem
        return CountriesCoordinator(
            navigationController: navigationController,
            popTracker: popTracker,
            dependencies: dependencies
        )
    }

    private func makeSettingsCoordinator(with navigationController: UINavigationController) -> SettingsCoordinator {
        let tabBarItem = UITabBarItem(title: "Settings".unlocalized, image: .tabBarSettings, selectedImage: nil)
        navigationController.tabBarItem = tabBarItem
        let settingsCoordinator = SettingsCoordinator(
            navigationController: navigationController,
            dependencies: dependencies
        )
        settingsCoordinator.delegate = self

        return settingsCoordinator
    }
}

// MARK: - SettingsCoordinatorDelegate

extension MainFlowCoordinator: SettingsCoordinatorDelegate {
    func settingsCoordinatorDidChangeUsername(_ coordinator: SettingsCoordinator) {
        delegate?.mainFlowCoordinatorDidChangeUsername(self)
    }
}
