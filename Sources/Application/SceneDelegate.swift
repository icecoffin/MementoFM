//
//  SceneDelegate.swift
//  MementoFM
//
//  Created by Dani on 28.06.26.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.backgroundColor = .systemBackground
        configureAppearance()

        let appCoordinator = AppCoordinator(window: window)
        appCoordinator.start()
        window.makeKeyAndVisible()

        log.debug(NSHomeDirectory())

        self.window = window
        self.appCoordinator = appCoordinator
    }

    private func configureAppearance() {
        UITableView.appearance().sectionHeaderTopPadding = 0
    }
}
