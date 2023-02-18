//
//  AppearanceConfigurator.swift
//  MementoFM
//
//  Created by Daniel on 07/12/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit
import CoreUI

final class AppearanceConfigurator {
    static func configureAppearance() {
        configureNavigationBarAppearance()
        configureTabBarItemAppearance()
        configureSearchBarAppearance()
        configureTableViewAppearance()
    }

    private static func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()

        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = .clear
        appearance.setBackIndicatorImage(.arrowLeft, transitionMaskImage: .arrowLeft)

        appearance.backButtonAppearance = UIBarButtonItemAppearance.init(style: .plain)

        appearance.titleTextAttributes = [.font: UIFont.navigationBarTitle]
        appearance.largeTitleTextAttributes = [.font: UIFont.navigationBarLargeTitle]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
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

    private static func configureTableViewAppearance() {
        if #available(iOS 15.0, *) {
            UITableView.appearance().sectionHeaderTopPadding = 0
        }
    }
}
