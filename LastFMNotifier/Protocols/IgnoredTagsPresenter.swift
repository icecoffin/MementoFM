//
//  IgnoredTagsPresenting.swift
//  LastFMNotifier
//
//  Created by Daniel on 27/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

protocol IgnoredTagsPresenter: NavigationFlowCoordinator, IgnoredTagsViewModelDelegate {
  func makeIgnoredTagsViewController(dependencies: IgnoredTagsViewModel.Dependencies) -> IgnoredTagsViewController
}

extension IgnoredTagsPresenter {
  func makeIgnoredTagsViewController(dependencies: IgnoredTagsViewModel.Dependencies) -> IgnoredTagsViewController {
    let viewModel = IgnoredTagsViewModel(dependencies: dependencies)
    viewModel.delegate = self
    let viewController = IgnoredTagsViewController(viewModel: viewModel)
    viewController.navigationItem.leftBarButtonItem = createBackButton()

    let rightView = IgnoredTagsNavigationRightView()
    rightView.onAddTapped = { [unowned viewModel] in
      viewModel.addNewIgnoredTag()
    }
    rightView.onSaveTapped = { [unowned viewModel] in
      viewModel.saveChanges()
    }
    rightView.sizeToFit()
    let rightBarButtonItem = UIBarButtonItem(customView: rightView)
    viewController.navigationItem.rightBarButtonItem = rightBarButtonItem

    viewController.hidesBottomBarWhenPushed = true
    return viewController
  }
}
