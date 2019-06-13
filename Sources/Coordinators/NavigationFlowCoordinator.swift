//
//  NavigationFlowCoordinator.swift
//  MementoFM
//
//  Created by Daniel on 05/01/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

protocol NavigationFlowCoordinator: Coordinator, NavigationControllerPopObserver {
  var navigationController: NavigationController { get }
}

extension NavigationFlowCoordinator {
  func makeBackButton(tapHandler: (() -> Void)? = nil) -> BlockBarButtonItem {
    let button = BlockBarButtonItem(image: .arrowLeft, style: .plain) { [unowned self] in
      self.navigationController.popViewController(animated: true)
      tapHandler?()
    }
    return button
  }
}

// MARK: - NavigationControllerPopObserver
extension NavigationFlowCoordinator {
  func navigationControllerPopTracker(_ tracker: NavigationControllerPopTracker,
                                      didPopViewController viewController: UIViewController) {
    if childCoordinators.isEmpty {
      didFinish?()
    } else {
      childCoordinators.removeLast()
    }
  }
}
