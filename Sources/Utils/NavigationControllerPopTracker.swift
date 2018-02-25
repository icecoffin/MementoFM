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

class NavigationControllerPopTracker: NSObject {
  private let navigationController: NavigationController
  private var observers = [NavigationControllerPopObserver]()

  init(navigationController: NavigationController) {
    self.navigationController = navigationController
    super.init()
    navigationController.delegate = self
  }

  func addObserver(_ observer: NavigationControllerPopObserver) {
    observers.append(observer)
  }

  func removeObserver(_ observer: NavigationControllerPopObserver) {
    if let index = observers.index(where: { $0 === observer }) {
      observers.remove(at: index)
    }
  }
}

extension NavigationControllerPopTracker: UINavigationControllerDelegate {
  func navigationController(_ navigationController: UINavigationController,
                            didShow viewController: UIViewController,
                            animated: Bool) {

    guard let poppingViewController = navigationController.poppingViewController() else {
      return
    }

    observers.last?.navigationControllerPopTracker(self, didPopViewController: poppingViewController)
  }
}
