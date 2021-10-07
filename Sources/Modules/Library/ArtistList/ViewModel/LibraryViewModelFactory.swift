//
//  ArtistListViewModelFactory.swift
//  MementoFM
//
//  Created by Daniel on 30/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

// MARK: - ArtistListViewModelFactory

protocol ArtistListViewModelFactory {
    func makeViewModel() -> ArtistListViewModel
}

// MARK: - LibraryViewModelFactory

final class LibraryViewModelFactory: ArtistListViewModelFactory {
    // MARK: - Private properties

    private let dependencies: LibraryViewModel.Dependencies

    // MARK: - Init

    init(dependencies: LibraryViewModel.Dependencies) {
        self.dependencies = dependencies
    }

    // MARK: - Public methods

    func makeViewModel() -> ArtistListViewModel {
        return LibraryViewModel(dependencies: dependencies)
    }
}

// MARK: - ArtistsByTagViewModelFactory

final class ArtistsByTagViewModelFactory: ArtistListViewModelFactory {
    // MARK: - Private properties

    private let dependencies: ArtistsByTagViewModel.Dependencies
    private let tagName: String

    // MARK: - Init

    init(tagName: String, dependencies: ArtistsByTagViewModel.Dependencies) {
        self.tagName = tagName
        self.dependencies = dependencies
    }

    // MARK: - Public methods

    func makeViewModel() -> ArtistListViewModel {
        return ArtistsByTagViewModel(tagName: tagName, dependencies: dependencies)
    }
}

// MARK: - ArtistsByCountryViewModelFactory

final class ArtistsByCountryViewModelFactory: ArtistListViewModelFactory {
    // MARK: - Private properties

    private let dependencies: ArtistsByCountryViewModel.Dependencies
    private let country: CountryType

    // MARK: - Init

    init(country: CountryType, dependencies: ArtistsByCountryViewModel.Dependencies) {
        self.country = country
        self.dependencies = dependencies
    }

    // MARK: - Public methods

    func makeViewModel() -> ArtistListViewModel {
        return ArtistsByCountryViewModel(country: country, dependencies: dependencies)
    }
}
