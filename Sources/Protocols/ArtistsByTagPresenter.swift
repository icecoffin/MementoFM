//
//  ArtistsByTagPresenter.swift
//  MementoFM
//
//  Created by Daniel on 29/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

protocol ArtistsByTagPresenter: NavigationFlowCoordinator, ArtistListViewModelDelegate {
  func makeLibraryViewController(forTagWithName tagName: String,
                                 dependencies: ArtistsByTagViewModel.Dependencies) -> ArtistListViewController
}

extension ArtistsByTagPresenter {
  func makeLibraryViewController(forTagWithName tagName: String,
                                 dependencies: ArtistsByTagViewModel.Dependencies) -> ArtistListViewController {
    let viewModel = ArtistsByTagViewModel(tagName: tagName, dependencies: dependencies)
    viewModel.delegate = self
    let viewController = ArtistListViewController(viewModel: viewModel)
    viewController.navigationItem.leftBarButtonItem = makeBackButton()
    viewController.title = viewModel.title
    return viewController
  }
}
