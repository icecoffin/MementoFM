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

class SimilarArtistsRemoteRequestStrategyTests: XCTestCase {
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
    let strategy = SimilarArtistsRemoteRequestStrategy(dependencies: dependencies)
    expect(strategy.minNumberOfIntersectingTags).to(equal(0))
  }

  func testGettingSimilarArtists() {
    artistService.stubSimilarArtists = similarArtists
    let strategy = SimilarArtistsRemoteRequestStrategy(dependencies: dependencies)
    var expectedSimilarArtists: [Artist] = []
    strategy.getSimilarArtists(for: sampleArtist).done { artists in
      expectedSimilarArtists = artists
    }.noError()
    expect(expectedSimilarArtists).toEventually(equal(similarArtists))
  }
}