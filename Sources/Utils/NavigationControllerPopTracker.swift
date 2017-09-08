//
//  NavigationControllerPopTracker.swift
//  MementoFM
//
//  Created by Daniel on 05/06/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

protocol NavigationControllerPopTrackerDelegate: class {
  func navigationControllerPopTracker(_ tracker: NavigationControllerPopTracker,
                                      didPopViewController viewController: UIViewController)
}

class NavigationControllerPopTracker: NSObject {
  private let navigationController: NavigationController
  fileprivate var delegates = [NavigationControllerPopTrackerDelegate]()

  init(navigationController: NavigationController) {
    self.navigationController = navigationController
    super.init()
    navigationController.delegate = self
  }

  func addDelegate(_ delegate: NavigationControllerPopTrackerDelegate) {
    delegates.append(delegate)
  }

  func removeDelegate(_ delegate: NavigationControllerPopTrackerDelegate) {
    if let index = delegates.index(where: { $0 === delegate }) {
      delegates.remove(at: index)
    }
  }

  func removeLastDelegate() {
    delegates.removeLast()
  }
}

extension NavigationControllerPopTracker: UINavigationControllerDelegate {
  func navigationController(_ navigationController: UINavigationController,
                            didShow viewController: UIViewController,
                            animated: Bool) {

    guard let poppingViewController = navigationController.poppingViewController() else {
      return
    }

    delegates.last?.navigationControllerPopTracker(self, didPopViewController: poppingViewController)
  }
}
