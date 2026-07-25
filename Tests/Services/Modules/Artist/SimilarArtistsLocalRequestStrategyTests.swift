//
//  SimilarArtistsLocalRequestStrategyTests.swift
//  MementoFMTests
//
//  Created by Daniel on 10/12/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM

final class SimilarArtistsLocalRequestStrategyTests: XCTestCase {
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
        let strategy = SimilarArtistsLocalRequestStrategy(dependencies: dependencies)
        XCTAssertEqual(strategy.minNumberOfIntersectingTags, 2)
    }

    func test_getSimilarArtists_getsCorrectValueFromArtistService() async throws {
        artistService.customArtistsWithIntersectingTopTags = similarArtists
        let strategy = SimilarArtistsLocalRequestStrategy(dependencies: dependencies)

        let expectedSimilarArtists = try await strategy.getSimilarArtists(for: sampleArtist)

        XCTAssertEqual(expectedSimilarArtists, similarArtists)
    }
}
