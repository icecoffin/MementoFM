//
//  AppDelegate.swift
//  MementoFM
//
//  Created by Daniel on 12/10/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit

let log = Logger.self

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private var appFlowController: AppFlowController?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if NSClassFromString("XCTestCase") != nil {
            return true
        }

        log.debug(NSHomeDirectory())

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = .systemBackground
        AppearanceConfigurator.configureAppearance()

        let migrator = RealmMigrator()
        migrator.performMigrations()

        let appFlowController = AppFlowController(window: window)
        appFlowController.start()

        self.window = window
        self.appFlowController = appFlowController

        return true
    }
}
