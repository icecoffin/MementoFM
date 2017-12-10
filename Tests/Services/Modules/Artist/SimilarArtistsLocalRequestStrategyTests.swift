//
//  SimilarArtistsLocalRequestStrategyTests.swift
//  MementoFMTests
//
//  Created by Daniel on 10/12/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble

class SimilarArtistsLocalRequestStrategyTests: XCTestCase {
  class Dependencies: SimilarArtistsRequestStrategy.Dependencies {
    let artistService: ArtistServiceProtocol

    init(artistService: ArtistServiceProtocol) {
      self.artistService = artistService
    }
  }

  let sampleArtist = ModelFactory.generateArtist()
  let similarArtists = ModelFactory.generateArtists(inAmount: 10)

  var artistService: StubArtistService!
  var dependencies: Dependencies!

  override func setUp() {
    super.setUp()
    artistService = StubArtistService()
    dependencies = Dependencies(artistService: artistService)
  }

  func testGettingNumberOfIntersectingTags() {
    let strategy = SimilarArtistsLocalRequestStrategy(dependencies: dependencies)
    expect(strategy.minNumberOfIntersectingTags).to(equal(2))
  }

  func testGettingSimilarArtists() {
    artistService.stubArtistsWithIntersectingTopTags = similarArtists
    let strategy = SimilarArtistsLocalRequestStrategy(dependencies: dependencies)
    var expectedSimilarArtists: [Artist] = []
    strategy.getSimilarArtists(for: sampleArtist).then { artists in
      expectedSimilarArtists = artists
    }.noError()
    expect(expectedSimilarArtists).toEventually(equal(similarArtists))
  }
}
