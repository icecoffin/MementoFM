//
//  NavigationController.swift
//  MementoFM
//
//  Created by Daniel on 20/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

// A UINavigationController subclass allowing to use custom back buttons along with the interactive pop gesture
class NavigationController: UINavigationController, UIGestureRecognizerDelegate {
  override func viewDidLoad() {
    super.viewDidLoad()
    interactivePopGestureRecognizer?.delegate = self
  }

  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return viewControllers.count > 1
  }
}

extension UINavigationController {
  func poppingViewController() -> UIViewController? {
    guard let fromViewController = transitionCoordinator?.viewController(forKey: .from),
      !viewControllers.contains(fromViewController) else {
        return nil
    }
    return fromViewController
  }
}
