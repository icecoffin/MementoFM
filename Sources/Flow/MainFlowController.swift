//
//  MainFlowController.swift
//  MementoFM
//
//  Created by Dani on 11.08.2024.
//  Copyright © 2024 icecoffin. All rights reserved.
//

import UIKit

// MARK: - MainFlowControllerDelegate

protocol MainFlowControllerDelegate: AnyObject {
    func mainFlowControllerDidChangeUsername(_ flowController: MainFlowController)
}

// MARK: - MainFlowController

final class MainFlowController: UIViewController, FlowController {
    private let dependencies: AppDependency

    weak var delegate: MainFlowControllerDelegate?

    init(dependencies: AppDependency) {
        self.dependencies = dependencies
        super.init(nibName: nil, bundle: nil)

        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        let tabBarController = UITabBarController()
        tabBarController.tabBar.isTranslucent = false

        let libraryNavigationController = UINavigationController()
        libraryNavigationController.navigationBar.prefersLargeTitles = true
        startLibraryFlow(in: libraryNavigationController)

        let tagsNavigationController = UINavigationController()
        tagsNavigationController.navigationBar.prefersLargeTitles = true
        showTagsFlow(in: tagsNavigationController)

        let countriesNavigationController = UINavigationController()
        countriesNavigationController.navigationBar.prefersLargeTitles = true
        showCountriesFlow(in: countriesNavigationController)

        let settingsNavigationController = UINavigationController()
        settingsNavigationController.navigationBar.prefersLargeTitles = true
        startSettingsFlow(in: settingsNavigationController)

        tabBarController.viewControllers = [
            libraryNavigationController,
            tagsNavigationController,
            countriesNavigationController,
            settingsNavigationController
        ]
        add(child: tabBarController)
    }

    private func startLibraryFlow(in navigationController: UINavigationController) {
        let tabBarItem = UITabBarItem(title: "Library".unlocalized, image: .tabBarLibrary, selectedImage: nil)
        navigationController.tabBarItem = tabBarItem
        let flowController = ArtistListFlowController(
            dependencies: dependencies,
            viewModelFactory: LibraryViewModelFactory(dependencies: dependencies)
        )
        navigationController.pushViewController(flowController, animated: false)
    }

    private func showTagsFlow(in navigationController: UINavigationController) {
        let tabBarItem = UITabBarItem(title: "Tags".unlocalized, image: .tabBarTags, selectedImage: nil)
        navigationController.tabBarItem = tabBarItem
        let flowController = TagsFlowController(dependencies: dependencies)
        navigationController.pushViewController(flowController, animated: false)
    }

    private func showCountriesFlow(in navigationController: UINavigationController) {
        let tabBarItem = UITabBarItem(title: "Countries".unlocalized, image: .tabBarCountries, selectedImage: nil)
        navigationController.tabBarItem = tabBarItem
        let flowController = CountriesFlowController(dependencies: dependencies)
        navigationController.pushViewController(flowController, animated: false)
    }

    private func startSettingsFlow(in navigationController: UINavigationController) {
        let tabBarItem = UITabBarItem(title: "Settings".unlocalized, image: .tabBarSettings, selectedImage: nil)
        navigationController.tabBarItem = tabBarItem
        let settingsFlowController = SettingsFlowController(dependencies: dependencies)
        settingsFlowController.delegate = self
        navigationController.pushViewController(settingsFlowController, animated: false)
    }
}

// MARK: - SettingsFlowControllerDelegate

extension MainFlowController: SettingsFlowControllerDelegate {
    func settingsFlowControllerDidChangeUsername(_ flowController: SettingsFlowController) {
        delegate?.mainFlowControllerDidChangeUsername(self)
    }
}
