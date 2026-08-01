//
//  SimilarsSectionTabViewModel.swift
//  MementoFM
//
//  Created by Daniel on 19/09/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine

// MARK: - SimilarsSectionTabViewModelDelegate

@MainActor
protocol SimilarsSectionTabViewModelDelegate: AnyObject {
    func similarsSectionTabViewModel(
        _ viewModel: SimilarsSectionTabViewModel,
        didSelectArtist artist: Artist
    )
}

// MARK: - SimilarsSectionTabViewModel

@MainActor
final class SimilarsSectionTabViewModel: ArtistSimilarsSectionViewModelProtocol {

    // MARK: - Private properties

    private let artist: Artist
    private let requestStrategy: SimilarArtistsRequestStrategy

    private var cellViewModels: [SimilarArtistCellViewModel] = []

    private var didUpdateSubject = PassthroughSubject<Result<Void, Error>, Never>()

    // MARK: - Public properties

    private(set) var isLoading: Bool = false

    let canSelectSimilarArtists: Bool

    var didUpdate: AnyPublisher<Result<Void, Error>, Never> {
        return didUpdateSubject.eraseToAnyPublisher()
    }

    weak var delegate: SimilarsSectionTabViewModelDelegate?

    var numberOfSimilarArtists: Int {
        return cellViewModels.count
    }

    var hasSimilarArtists: Bool {
        return !cellViewModels.isEmpty
    }

    var emptyDataSetText: String {
        return "There are no similar artists.".unlocalized
    }

    // MARK: - Init

    init(
        artist: Artist,
        canSelectSimilarArtists: Bool,
        requestStrategy: SimilarArtistsRequestStrategy
    ) {
        self.artist = artist
        self.canSelectSimilarArtists = canSelectSimilarArtists
        self.requestStrategy = requestStrategy
        self.cellViewModels = []
    }

    // MARK: - Private methods

    private func calculateSimilarArtists() async {
        isLoading = true

        do {
            let artists = try await self.requestStrategy.getSimilarArtists(for: artist)
            self.isLoading = false
            self.createCellViewModels(from: artists)
            self.didUpdateSubject.send(.success(()))
        } catch {
            self.isLoading = false
            self.didUpdateSubject.send(.failure(error))
        }
    }

    private func createCellViewModels(from artists: [Artist]) {
        let artistsWithCommonTags = artists
            .map { artist -> (Artist, [String]) in
                let commonTags = self.artist.intersectingTopTagNames(with: artist)
                return (artist, commonTags)
        }
        .filter { (_, commonTags) in
            return commonTags.count >= requestStrategy.minNumberOfIntersectingTags
        }
        .sorted { (first: (artist: Artist, commonTags: [String]), second: (artist: Artist, commonTags: [String])) in
            let commonTagsCount1 = first.commonTags.count
            let commonTagsCount2 = second.commonTags.count
            if commonTagsCount1 == commonTagsCount2 {
                return first.artist.playcount > second.artist.playcount
            }
            return commonTagsCount1 > commonTagsCount2
        }

        cellViewModels = zip(artistsWithCommonTags, 0..<artistsWithCommonTags.count)
            .map { (artistWithCommonTags, index) in
                let (artist, commonTags) = artistWithCommonTags
                return SimilarArtistCellViewModel(artist: artist, commonTags: commonTags, index: index + 1)
        }
    }

    // MARK: - Public methods

    func cellViewModel(at indexPath: IndexPath) -> SimilarArtistCellViewModelProtocol {
        return cellViewModels[indexPath.item]
    }

    func selectArtist(at indexPath: IndexPath) {
        let cellViewModel = cellViewModels[indexPath.row]
        delegate?.similarsSectionTabViewModel(self, didSelectArtist: cellViewModel.artist)
    }

    func getSimilarArtists() async {
        if !isLoading && cellViewModels.isEmpty {
            await calculateSimilarArtists()
        } else {
            didUpdateSubject.send(.success(()))
        }
    }
}
