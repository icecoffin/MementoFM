//
//  NavigationControllerPopTracker.swift
//  MementoFM
//
//  Created by Daniel on 05/06/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

protocol NavigationControllerPopObserver: class {
  func navigationControllerPopTracker(_ tracker: NavigationControllerPopTracker,
                                      didPopViewController viewController: UIViewController)
}

struct NavigationControllerPopObserverContainer {
  weak var value: NavigationControllerPopObserver?
}

class NavigationControllerPopTracker: NSObject {
  private let navigationController: NavigationController
  private var viewControllerToObservers: [UIViewController: NavigationControllerPopObserverContainer] = [:]

  init(navigationController: NavigationController) {
    self.navigationController = navigationController
    super.init()
    navigationController.delegate = self
  }

  func addObserver(_ observer: NavigationControllerPopObserver,
                   forPopTransitionOf viewController: UIViewController) {
    let wrappedObserver = NavigationControllerPopObserverContainer(value: observer)
    viewControllerToObservers[viewController] = wrappedObserver
  }
}

extension NavigationControllerPopTracker: UINavigationControllerDelegate {
  func navigationController(_ navigationController: UINavigationController,
                            didShow viewController: UIViewController,
                            animated: Bool) {
    guard let poppingViewController = navigationController.poppingViewController() else {
      return
    }

    if let wrappedObserver = viewControllerToObservers[poppingViewController] {
      let observer = wrappedObserver.value
      observer?.navigationControllerPopTracker(self, didPopViewController: poppingViewController)
      viewControllerToObservers.removeValue(forKey: poppingViewController)
    }
  }
}
