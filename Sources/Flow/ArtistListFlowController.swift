//
//  ArtistListFlowController.swift
//  MementoFM
//
//  Created by Dani on 10.08.2024.
//  Copyright © 2024 icecoffin. All rights reserved.
//

import UIKit

final class ArtistListFlowController: UIViewController, FlowController {
    private let dependencies: AppDependency
    private let viewModelFactory: ArtistListViewModelFactory

    init(
        dependencies: AppDependency,
        viewModelFactory: ArtistListViewModelFactory
    ) {
        self.dependencies = dependencies
        self.viewModelFactory = viewModelFactory
        super.init(nibName: nil, bundle: nil)

        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        let viewModel = viewModelFactory.makeViewModel()
        viewModel.delegate = self

        let searchController = UISearchController(searchResultsController: nil)
        let viewController = ArtistListViewController(searchController: searchController, viewModel: viewModel)
        viewController.navigationItem.searchController = searchController
        viewController.navigationItem.hidesSearchBarWhenScrolling = false

        title = viewModel.title
        navigationItem.backButtonDisplayMode = .minimal

        add(child: viewController)
    }

    private func openArtist(_ artist: Artist) {
        let viewModel = ArtistViewModel(artist: artist, dependencies: dependencies)
        viewModel.delegate = self
        let dataSource = ArtistDataSource(viewModel: viewModel)

        let viewController = ArtistViewController(dataSource: dataSource)
        viewController.title = viewModel.title
        viewController.navigationItem.backButtonDisplayMode = .minimal
        viewController.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - ArtistListViewModelDelegate

extension ArtistListFlowController: ArtistListViewModelDelegate {
    func artistListViewModel(_ viewModel: ArtistListViewModel, didSelectArtist artist: Artist) {
        openArtist(artist)
    }
}

// MARK: - ArtistViewModelDelegate

extension ArtistListFlowController: ArtistViewModelDelegate {
    func artistViewModel(_ viewModel: ArtistViewModel, didSelectTagWithName name: String) {
        let viewModelFactory = ArtistsByTagViewModelFactory(tagName: name, dependencies: dependencies)
        let artistListFlowController = ArtistListFlowController(
            dependencies: dependencies,
            viewModelFactory: viewModelFactory
        )
        navigationController?.pushViewController(artistListFlowController, animated: true)
    }

    func artistViewModel(_ viewModel: ArtistViewModel, didSelectArtist artist: Artist) {
        openArtist(artist)
    }
}
