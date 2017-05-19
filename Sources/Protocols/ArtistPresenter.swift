//
//  ArtistPresenter.swift
//  LastFMNotifier
//
//  Created by Daniel on 19/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

protocol ArtistPresenter: NavigationFlowCoordinator {
  func makeArtistViewController(for artist: Artist, dependencies: ArtistViewModel.Dependencies) -> ArtistViewController
}

extension ArtistPresenter {
  func makeArtistViewController(for artist: Artist, dependencies: ArtistViewModel.Dependencies) -> ArtistViewController {
    let viewModel = ArtistViewModel(artist: artist, dependencies: dependencies)
    let dataSource = ArtistDataSource(viewModel: viewModel)

    let viewController = ArtistViewController(dataSource: dataSource)
    viewController.title = viewModel.title
    viewController.navigationItem.leftBarButtonItem = makeBackButton()
    viewController.hidesBottomBarWhenPushed = true

    return viewController
  }
}
