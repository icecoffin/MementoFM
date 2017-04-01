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
  func createBackButton() -> BlockBarButtonItem {
    let button = BlockBarButtonItem(image: #imageLiteral(resourceName: "icon_back"), style: .plain) { [unowned self] in
      self.navigationController.popViewController(animated: true)
    }
    return button
  }
}
