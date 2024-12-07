//
//  NavigationFlowCoordinator.swift
//  MementoFM
//
//  Created by Daniel on 05/01/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

protocol NavigationFlowCoordinator: Coordinator, NavigationControllerPopObserver {
    var navigationController: UINavigationController { get }
}

// MARK: - NavigationControllerPopObserver

extension NavigationFlowCoordinator {
    func navigationControllerPopTracker(
        _ tracker: NavigationControllerPopTracker,
        didPopViewController viewController: UIViewController
    ) {
        if childCoordinators.isEmpty {
            didFinish?()
        } else {
            childCoordinators.removeLast()
        }
    }
}
