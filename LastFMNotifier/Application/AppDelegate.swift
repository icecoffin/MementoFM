//
//  AppDelegate.swift
//  LastFMNotifier
//
//  Created by Daniel on 12/10/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit
import SwiftyBeaver

let log = SwiftyBeaver.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var appCoordinator: AppCoordinator?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    setupLogging()

    let window = UIWindow(frame: UIScreen.main.bounds)
    window.backgroundColor = .white
    AppearanceConfigurator.configureAppearance()

    let appCoordinator = AppCoordinator(window: window)
    appCoordinator.start()
    window.makeKeyAndVisible()

    self.window = window
    self.appCoordinator = appCoordinator

    return true
  }

  private func setupLogging() {
    let console = ConsoleDestination()
    console.format = "$Dyyyy-MM-dd HH:mm:ss.SSS$d [$L] $M"
    log.addDestination(console)
    log.debug(NSHomeDirectory())
  }
}
