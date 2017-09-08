//
//  SyncPresenter.swift
//  MementoFM
//
//  Created by Daniel on 01/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

protocol SyncPresenter: NavigationFlowCoordinator, SyncViewModelDelegate {
  func makeSyncViewController(dependencies: AppDependency) -> SyncViewController
}

extension SyncPresenter {
  func makeSyncViewController(dependencies: AppDependency) -> SyncViewController {
    let viewModel = SyncViewModel(dependencies: dependencies)
    viewModel.delegate = self
    let viewController = SyncViewController(viewModel: viewModel)
    return viewController
  }
}
