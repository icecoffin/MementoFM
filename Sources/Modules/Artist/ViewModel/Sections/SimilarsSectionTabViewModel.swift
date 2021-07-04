//
//  SimilarsSectionTabViewModel.swift
//  MementoFM
//
//  Created by Daniel on 19/09/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

protocol SimilarsSectionTabViewModelDelegate: AnyObject {
    func similarsSectionTabViewModel(_ viewModel: SimilarsSectionTabViewModel,
                                     didSelectArtist artist: Artist)
}

final class SimilarsSectionTabViewModel: ArtistSimilarsSectionViewModelProtocol {
    typealias Dependencies = HasArtistService

    private let artist: Artist
    private let requestStrategy: SimilarArtistsRequestStrategy
    private let dependencies: Dependencies

    private var cellViewModels: [SimilarArtistCellViewModel] = []
    private(set) var isLoading: Bool = false

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

    init(artist: Artist, requestStrategy: SimilarArtistsRequestStrategy, dependencies: Dependencies) {
        self.artist = artist
        self.requestStrategy = requestStrategy
        self.dependencies = dependencies
        self.cellViewModels = []
    }

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

    private func calculateSimilarArtists() {
        isLoading = true
        requestStrategy.getSimilarArtists(for: artist).map { [weak self] artists in
            self?.createCellViewModels(from: artists)
        }.done { _ in
            self.isLoading = false
            self.didUpdateData?()
        }.catch { error in
            self.isLoading = false
            self.didReceiveError?(error)
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
}
