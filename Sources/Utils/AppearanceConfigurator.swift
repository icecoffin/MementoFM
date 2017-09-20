//
//  AppearanceConfigurator.swift
//  MementoFM
//
//  Created by Daniel on 07/12/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit

enum AppearanceConfigurator {
  static func configureAppearance() {
    configureNavigationBarAppearance()
    configureTabBarItemAppearance()
    configureSearchBarAppearance()
  }

  private static func configureNavigationBarAppearance() {
    let appearance = UINavigationBar.appearance()
    appearance.titleTextAttributes = [NSAttributedStringKey.font: Fonts.ralewayBold(withSize: 16)]
  }

  private static func configureTabBarItemAppearance() {
    let appearance = UITabBarItem.appearance()
    appearance.setTitleTextAttributes([NSAttributedStringKey.font: Fonts.raleway(withSize: 9)], for: .normal)
  }

  private static func configureSearchBarAppearance() {
    let textFieldAppearance = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
    textFieldAppearance.defaultTextAttributes = [NSAttributedStringKey.font.rawValue: Fonts.raleway(withSize: 14)]

    let barButtonItemAppearance = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self])
    barButtonItemAppearance.setTitleTextAttributes([NSAttributedStringKey.font: Fonts.raleway(withSize: 16)], for: .normal)
  }
}
