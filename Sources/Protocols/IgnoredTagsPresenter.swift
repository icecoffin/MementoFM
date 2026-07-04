//
//  IgnoredTagsPresenting.swift
//  MementoFM
//
//  Created by Daniel on 27/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

@MainActor
protocol IgnoredTagsPresenter: NavigationFlowCoordinator, IgnoredTagsViewModelDelegate {
    func makeIgnoredTagsViewController(
        dependencies: IgnoredTagsViewModel.Dependencies,
        shouldAddDefaultTags: Bool
    ) -> IgnoredTagsViewController
}

extension IgnoredTagsPresenter {
    func makeIgnoredTagsViewController(
        dependencies: IgnoredTagsViewModel.Dependencies,
        shouldAddDefaultTags: Bool
    ) -> IgnoredTagsViewController {
        let viewModel = IgnoredTagsViewModel(dependencies: dependencies, shouldAddDefaultTags: shouldAddDefaultTags)
        viewModel.delegate = self
        let viewController = IgnoredTagsViewController(viewModel: viewModel)
        viewController.title = "Ignored Tags".unlocalized

        let addButton = BlockBarButtonItem(image: .plus, style: .plain) { [unowned viewModel] in
            viewModel.addNewIgnoredTag()
        }

        let doneButton = BlockBarButtonItem(image: .checkmark, style: .plain) { [unowned viewModel] in
            Task {
                await viewModel.saveChanges()
            }
        }

        viewController.navigationItem.rightBarButtonItems = [doneButton, addButton]

        viewController.hidesBottomBarWhenPushed = true
        return viewController
    }
}
