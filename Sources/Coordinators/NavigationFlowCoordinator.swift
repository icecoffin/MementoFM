//
//  NavigationFlowCoordinator.swift
//  LastFMNotifier
//
//  Created by Daniel on 05/01/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

protocol NavigationFlowCoordinator: Coordinator {
  var navigationController: UINavigationController { get }
}

extension NavigationFlowCoordinator {
  func makeBackButton(tapHandler: (() -> Void)? = nil) -> BlockBarButtonItem {
    let button = BlockBarButtonItem(image: #imageLiteral(resourceName: "icon_back"), style: .plain) { [unowned self] in
      self.navigationController.popViewController(animated: true)
      tapHandler?()
    }
    return button
  }
}

extension UINavigationController {
  func popViewController(animated: Bool, completion: (() -> Void)?) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    popViewController(animated: animated)
    CATransaction.commit()
  }
}
