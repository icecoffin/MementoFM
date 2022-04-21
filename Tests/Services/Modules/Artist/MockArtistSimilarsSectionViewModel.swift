//
//  MockArtistSimilarsSectionViewModel.swift
//  MementoFMTests
//
//  Created by Daniel on 09/12/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import Combine

class MockArtistSimilarsSectionViewModel: ArtistSimilarsSectionViewModelProtocol {
    var didUpdateDataSubject = PassthroughSubject<Void, Error>()
    var didUpdateData: AnyPublisher<Void, Error> {
        return didUpdateDataSubject.eraseToAnyPublisher()
    }

    var numberOfSimilarArtists = 0
    var hasSimilarArtists = false
    var canSelectSimilarArtists = false
    var isLoading = false
    var emptyDataSetText = ""

    var didCallGetSimilarArtists = false
    func getSimilarArtists() {
        didCallGetSimilarArtists = true
    }

    var cellViewModelIndexPath: IndexPath?
    var customCellViewModel: SimilarArtistCellViewModel!
    func cellViewModel(at indexPath: IndexPath) -> SimilarArtistCellViewModelProtocol {
        cellViewModelIndexPath = indexPath
        return customCellViewModel
    }

    var selectedArtistIndexPath: IndexPath?
    func selectArtist(at indexPath: IndexPath) {
        selectedArtistIndexPath = indexPath
    }
}

// swiftlint:disable:next type_name
class MockArtistSimilarsSectionTabViewModelFactory: ArtistSimilarsSectionTabViewModelFactoryProtocol {
    var firstTabViewModel = MockArtistSimilarsSectionViewModel()
    var secondTabViewModel = MockArtistSimilarsSectionViewModel()

    func makeTabViewModels(for artist: Artist,
                           dependencies: ArtistSimilarsSectionViewModel.Dependencies,
                           delegate: SimilarsSectionTabViewModelDelegate) -> [ArtistSimilarsSectionViewModelProtocol] {
        return [firstTabViewModel, secondTabViewModel]
    }
}
