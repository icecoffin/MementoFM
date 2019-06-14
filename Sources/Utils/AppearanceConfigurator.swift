//
//  AppearanceConfigurator.swift
//  MementoFM
//
//  Created by Daniel on 07/12/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit
import SVProgressHUD

enum AppearanceConfigurator {
  static func configureAppearance() {
    configureNavigationBarAppearance()
    configureTabBarItemAppearance()
    configureSearchBarAppearance()
    configureHUDAppearance()
  }

  private static func configureNavigationBarAppearance() {
    let appearance = UINavigationBar.appearance()
    appearance.titleTextAttributes = [.font: UIFont.navigationBarTitle]
    appearance.largeTitleTextAttributes = [.font: UIFont.navigationBarLargeTitle]
  }

  private static func configureTabBarItemAppearance() {
    let appearance = UITabBarItem.appearance()
    appearance.setTitleTextAttributes([.font: UIFont.tabBarItem], for: .normal)
  }

  private static func configureSearchBarAppearance() {
    let textFieldAppearance = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
    textFieldAppearance.defaultTextAttributes = [.font: UIFont.secondaryContent]

    let barButtonItemAppearance = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self])
    barButtonItemAppearance.setTitleTextAttributes([.font: UIFont.primaryContent], for: .normal)
  }

  private static func configureHUDAppearance() {
    SVProgressHUD.setDefaultMaskType(.black)
  }
}
