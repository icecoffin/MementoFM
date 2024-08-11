//
//  TagsFlowController.swift
//  MementoFM
//
//  Created by Dani on 11.08.2024.
//  Copyright © 2024 icecoffin. All rights reserved.
//

import UIKit

final class TagsFlowController: UIViewController, FlowController {
    private let dependencies: AppDependency

    init(dependencies: AppDependency) {
        self.dependencies = dependencies
        super.init(nibName: nil, bundle: nil)

        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        title = "Tags".unlocalized
        navigationItem.backButtonDisplayMode = .minimal

        let viewModel = TagsViewModel(dependencies: dependencies)
        viewModel.delegate = self

        let searchController = UISearchController(searchResultsController: nil)
        let viewController = TagsViewController(searchController: searchController, viewModel: viewModel)
        viewController.navigationItem.searchController = searchController
        viewController.navigationItem.hidesSearchBarWhenScrolling = false

        add(child: viewController)
    }
}

// MARK: - TagsViewModelDelegate

extension TagsFlowController: TagsViewModelDelegate {
    func tagsViewModel(_ viewModel: TagsViewModel, didSelectTagWithName name: String) {
        let viewModelFactory = ArtistsByTagViewModelFactory(tagName: name, dependencies: dependencies)
        let artistListFlowController = ArtistListFlowController(
            dependencies: dependencies,
            viewModelFactory: viewModelFactory
        )
        navigationController?.pushViewController(artistListFlowController, animated: true)
    }
}
