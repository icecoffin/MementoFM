//
//  CountriesCoordinator.swift
//  MementoFM
//
//  Created by Dani on 21.12.2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import UIKit

// MARK: - CountriesCoordinator

final class CountriesCoordinator: NavigationFlowCoordinator {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var didFinish: (() -> Void)?

    private let dependencies: AppDependency
    private let popTracker: NavigationControllerPopTracker

    init(navigationController: UINavigationController,
         popTracker: NavigationControllerPopTracker,
         dependencies: AppDependency) {
        self.navigationController = navigationController
        self.popTracker = popTracker
        self.dependencies = dependencies
    }

    func start() {
        let viewModel = CountriesViewModel(dependencies: dependencies)
        viewModel.delegate = self
        let viewController = CountriesViewController(viewModel: viewModel)
        viewController.title = "Countries".unlocalized
        viewController.navigationItem.backButtonDisplayMode = .minimal
        navigationController.pushViewController(viewController, animated: false)
    }
}

// MARK: - CountriesViewModelDelegate

extension CountriesCoordinator: CountriesViewModelDelegate {
    func countriesViewModel(_ viewModel: CountriesViewModel, didSelectCountry country: CountryType) {
        let viewModelFactory = ArtistsByCountryViewModelFactory(country: country, dependencies: dependencies)
        let artistListCoordinator = ArtistListCoordinator(navigationController: navigationController,
                                                          popTracker: popTracker,
                                                          shouldStartAnimated: true,
                                                          viewModelFactory: viewModelFactory,
                                                          dependencies: dependencies)
        addChildCoordinator(artistListCoordinator)
        artistListCoordinator.start()
    }
}
