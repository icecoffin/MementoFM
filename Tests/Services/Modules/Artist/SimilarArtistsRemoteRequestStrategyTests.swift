//
//  SimilarArtistsRemoteRequestStrategyTests.swift
//  MementoFMTests
//
//  Created by Daniel on 10/12/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble
import TransientModels

final class SimilarArtistsRemoteRequestStrategyTests: XCTestCase {
    private final class Dependencies: SimilarArtistsRequestStrategy.Dependencies {
        let artistService: ArtistServiceProtocol

        init(artistService: ArtistServiceProtocol) {
            self.artistService = artistService
        }
    }

    private let sampleArtist = ModelFactory.generateArtist()
    private let similarArtists = ModelFactory.generateArtists(inAmount: 10)

    private var artistService: MockArtistService!
    private var dependencies: Dependencies!

    override func setUp() {
        super.setUp()

        artistService = MockArtistService()
        dependencies = Dependencies(artistService: artistService)
    }

    override func tearDown() {
        artistService = nil
        dependencies = nil

        super.tearDown()
    }

    func test_minNumberOfIntersectingTags_returnsCorrectValueFromStrategy() {
        let strategy = SimilarArtistsRemoteRequestStrategy(dependencies: dependencies)
        expect(strategy.minNumberOfIntersectingTags) == 0
    }

    func test_getSimilarArtists_getsCorrectValueFromArtistService() {
        artistService.customSimilarArtists = similarArtists
        let strategy = SimilarArtistsRemoteRequestStrategy(dependencies: dependencies)
        var expectedSimilarArtists: [Artist] = []

        _ = strategy.getSimilarArtists(for: sampleArtist)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { artists in
                expectedSimilarArtists = artists
            })

        expect(expectedSimilarArtists) == similarArtists
    }
}
