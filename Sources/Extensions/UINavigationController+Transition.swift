//
//  UINavigationController+Transition.swift
//  MementoFM
//
//  Created by Dani on 05.10.2021.
//  Copyright © 2021 icecoffin. All rights reserved.
//

import UIKit

extension UINavigationController {
    func poppingViewController() -> UIViewController? {
        guard let fromViewController = transitionCoordinator?.viewController(forKey: .from),
            !viewControllers.contains(fromViewController) else {
                return nil
        }
        return fromViewController
    }
}
