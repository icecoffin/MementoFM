//
//  IgnoredTagsPresenting.swift
//  MementoFM
//
//  Created by Daniel on 27/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

protocol IgnoredTagsPresenter: NavigationFlowCoordinator, IgnoredTagsViewModelDelegate {
  func makeIgnoredTagsViewController(dependencies: IgnoredTagsViewModel.Dependencies,
                                     shouldAddDefaultTags: Bool) -> IgnoredTagsViewController
}

extension IgnoredTagsPresenter {
  func makeIgnoredTagsViewController(dependencies: IgnoredTagsViewModel.Dependencies,
                                     shouldAddDefaultTags: Bool) -> IgnoredTagsViewController {
    let viewModel = IgnoredTagsViewModel(dependencies: dependencies, shouldAddDefaultTags: shouldAddDefaultTags)
    viewModel.delegate = self
    let viewController = IgnoredTagsViewController(viewModel: viewModel)
    viewController.title = "Ignored Tags".unlocalized
    viewController.navigationItem.leftBarButtonItem = makeBackButton()

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
