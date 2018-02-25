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

  func shouldFinishAfterPopping(viewController: UIViewController) -> Bool
}

extension NavigationFlowCoordinator {
  func makeBackButton(tapHandler: (() -> Void)? = nil) -> BlockBarButtonItem {
    let button = BlockBarButtonItem(image: #imageLiteral(resourceName: "icon_back"), style: .plain) { [unowned self] in
      self.navigationController.popViewController(animated: true)
      tapHandler?()
    }
    return button
  }

  func shouldFinishAfterPopping(viewController: UIViewController) -> Bool {
    return false
  }
}

// MARK: - NavigationControllerPopTracker delegate
extension NavigationFlowCoordinator {
  func navigationControllerPopTracker(_ tracker: NavigationControllerPopTracker,
                                      didPopViewController viewController: UIViewController) {
    if shouldFinishAfterPopping(viewController: viewController) {
      if childCoordinators.isEmpty {
        tracker.removeObserver(self)
        onDidFinish?()
      } else {
        if let coordinator = childCoordinators.last as? NavigationControllerPopObserver {
          tracker.removeObserver(coordinator)
        }
        childCoordinators.removeLast()
      }
    }
  }
}
