//
//  SimilarArtistsRequestStrategy.swift
//  MementoFM
//
//  Created by Daniel on 16/09/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

// MARK: - SimilarArtistsRequestStrategy

protocol SimilarArtistsRequestStrategy {
    typealias Dependencies = HasArtistService

    var minNumberOfIntersectingTags: Int { get }

    func getSimilarArtists(for artist: Artist) -> Promise<[Artist]>
}

// MARK: - SimilarArtistsLocalRequestStrategy

final class SimilarArtistsLocalRequestStrategy: SimilarArtistsRequestStrategy {
    // MARK: - Private properties

    private let dependencies: Dependencies

    // MARK: - Public properties

    var minNumberOfIntersectingTags: Int {
        return 2
    }

    // MARK: - Init

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    // MARK: - Public methods

    func getSimilarArtists(for artist: Artist) -> Promise<[Artist]> {
        let similarArtists = dependencies.artistService.artistsWithIntersectingTopTags(for: artist)
        return .value(similarArtists)
    }
}

// MARK: - SimilarArtistsRemoteRequestStrategy

final class SimilarArtistsRemoteRequestStrategy: SimilarArtistsRequestStrategy {
    // MARK: - Private properties

    private let dependencies: Dependencies

    // MARK: - Public properties

    var minNumberOfIntersectingTags: Int {
        return 0
    }

    // MARK: - Init

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    // MARK: - Public methods

    func getSimilarArtists(for artist: Artist) -> Promise<[Artist]> {
        return dependencies.artistService.getSimilarArtists(for: artist)
    }
}
