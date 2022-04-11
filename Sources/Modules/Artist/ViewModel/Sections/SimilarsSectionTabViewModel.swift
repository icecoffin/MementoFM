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

protocol SimilarsSectionTabViewModelDelegate: AnyObject {
    func similarsSectionTabViewModel(_ viewModel: SimilarsSectionTabViewModel,
                                     didSelectArtist artist: Artist)
}

// MARK: - SimilarsSectionTabViewModel

final class SimilarsSectionTabViewModel: ArtistSimilarsSectionViewModelProtocol {
    typealias Dependencies = HasArtistService

    // MARK: - Private properties

    private let artist: Artist
    private let requestStrategy: SimilarArtistsRequestStrategy
    private let dependencies: Dependencies

    private var cellViewModels: [SimilarArtistCellViewModel] = []
    private var cancelBag = Set<AnyCancellable>()

    // MARK: - Public properties

    private(set) var isLoading: Bool = false

    let canSelectSimilarArtists: Bool

    var didUpdateData: (() -> Void)?
    var didReceiveError: ((Error) -> Void)?

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

    init(artist: Artist,
         canSelectSimilarArtists: Bool,
         requestStrategy: SimilarArtistsRequestStrategy,
         dependencies: Dependencies) {
        self.artist = artist
        self.canSelectSimilarArtists = canSelectSimilarArtists
        self.requestStrategy = requestStrategy
        self.dependencies = dependencies
        self.cellViewModels = []
    }

    // MARK: - Private methods

    private func calculateSimilarArtists() {
        isLoading = true
        requestStrategy.getSimilarArtists(for: artist)
            .sink { [weak self] completion in
                guard let self = self else { return }

                self.isLoading = false
                switch completion {
                case .finished:
                    self.didUpdateData?()
                case .failure(let error):
                    self.didReceiveError?(error)
                }
            } receiveValue: { [weak self] artists in
                self?.createCellViewModels(from: artists)
            }
            .store(in: &cancelBag)
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

    func getSimilarArtists() {
        if !isLoading && cellViewModels.isEmpty {
            calculateSimilarArtists()
        } else {
            didUpdateData?()
        }
    }
}
