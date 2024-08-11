//
//  ArtistListFlowController.swift
//  MementoFM
//
//  Created by Dani on 10.08.2024.
//  Copyright © 2024 icecoffin. All rights reserved.
//

import UIKit

final class CountriesFlowController: UIViewController, FlowController {
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
        title = "Countries".unlocalized
        navigationItem.backButtonDisplayMode = .minimal

        let viewModel = CountriesViewModel(dependencies: dependencies)
        viewModel.delegate = self
        let viewController = CountriesViewController(viewModel: viewModel)
        add(child: viewController)
    }
}

// MARK: - CountriesViewModelDelegate

extension CountriesFlowController: CountriesViewModelDelegate {
    func countriesViewModel(_ viewModel: CountriesViewModel, didSelectCountry country: CountryType) {
        let viewModelFactory = ArtistsByCountryViewModelFactory(country: country, dependencies: dependencies)
        let artistListFlowController = ArtistListFlowController(
            dependencies: dependencies,
            viewModelFactory: viewModelFactory
        )
        navigationController?.pushViewController(artistListFlowController, animated: true)
    }
}
