//
//  StubArtistSimilarsSectionViewModel.swift
//  MementoFMTests
//
//  Created by Daniel on 09/12/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM

class StubArtistSimilarsSectionViewModel: ArtistSimilarsSectionViewModelProtocol {
  var onDidUpdateData: (() -> Void)?
  var onDidReceiveError: ((Error) -> Void)?

  var stubNumberOfSimilarArtists = 0
  var numberOfSimilarArtists: Int {
    return stubNumberOfSimilarArtists
  }

  var stubHasSimilarArtists = false
  var hasSimilarArtists: Bool {
    return stubHasSimilarArtists
  }

  var stubIsLoading = false
  var isLoading: Bool {
    return stubIsLoading
  }

  var stubEmptyDataSetText = ""
  var emptyDataSetText: String {
    return stubEmptyDataSetText
  }

  var didCallGetSimilarArtists = false
  func getSimilarArtists() {
    didCallGetSimilarArtists = true
  }

  var cellViewModelIndexPath: IndexPath?
  var stubCellViewModel: SimilarArtistCellViewModel!
  func cellViewModel(at indexPath: IndexPath) -> SimilarArtistCellViewModelProtocol {
    cellViewModelIndexPath = indexPath
    return stubCellViewModel
  }

  var selectedArtistIndexPath: IndexPath?
  func selectArtist(at indexPath: IndexPath) {
    selectedArtistIndexPath = indexPath
  }
}

// swiftlint:disable:next type_name
class StubArtistSimilarsSectionTabViewModelFactory: ArtistSimilarsSectionTabViewModelFactoryProtocol {
  var firstTabViewModel = StubArtistSimilarsSectionViewModel()
  var secondTabViewModel = StubArtistSimilarsSectionViewModel()

  func makeTabViewModels(for artist: Artist,
                         dependencies: ArtistSimilarsSectionViewModel.Dependencies,
                         delegate: SimilarsSectionTabViewModelDelegate) -> [ArtistSimilarsSectionViewModelProtocol] {
    return [firstTabViewModel, secondTabViewModel]
  }
}
