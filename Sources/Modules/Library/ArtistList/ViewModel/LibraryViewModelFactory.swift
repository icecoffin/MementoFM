//
//  ArtistListViewModelFactory.swift
//  MementoFM
//
//  Created by Daniel on 30/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

protocol ArtistListViewModelFactory {
  func makeViewModel() -> ArtistListViewModel
}

final class LibraryViewModelFactory: ArtistListViewModelFactory {
  private let dependencies: LibraryViewModel.Dependencies

  init(dependencies: LibraryViewModel.Dependencies) {
    self.dependencies = dependencies
  }

  func makeViewModel() -> ArtistListViewModel {
    return LibraryViewModel(dependencies: dependencies)
  }
}

final class ArtistsByTagViewModelFactory: ArtistListViewModelFactory {
  private let dependencies: ArtistsByTagViewModel.Dependencies
  private let tagName: String

  init(tagName: String, dependencies: ArtistsByTagViewModel.Dependencies) {
    self.tagName = tagName
    self.dependencies = dependencies
  }

  func makeViewModel() -> ArtistListViewModel {
    return ArtistsByTagViewModel(tagName: tagName, dependencies: dependencies)
  }
}

final class ArtistsByCountryViewModelFactory: ArtistListViewModelFactory {
  private let dependencies: ArtistsByCountryViewModel.Dependencies
  private let country: CountryType

  init(country: CountryType, dependencies: ArtistsByCountryViewModel.Dependencies) {
    self.country = country
    self.dependencies = dependencies
  }

  func makeViewModel() -> ArtistListViewModel {
    return ArtistsByCountryViewModel(country: country, dependencies: dependencies)
  }
}
