//
//  RecentTracksProcessorTests.swift
//  MementoFMTests
//
//  Created by Daniel on 01/12/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble
import PromiseKit

class RecentTracksProcessorTests: XCTestCase {
  var realmService: RealmService!

  override func setUp() {
    super.setUp()
    realmService = RealmService {
      return RealmFactory.inMemoryRealm()
    }
  }

  override func tearDown() {
    realmService = nil
    super.tearDown()
  }

  func testProcessingTracks() {
    let artist1 = Artist(name: "Artist1",
                         playcount: 1,
                         urlString: "",
                         imageURLString: nil,
                         needsTagsUpdate: false,
                         tags: [],
                         topTags: [])
    let artist2 = Artist(name: "Artist2",
                         playcount: 1,
                         urlString: "",
                         imageURLString: nil,
                         needsTagsUpdate: false,
                         tags: [],
                         topTags: [])
    let artist3 = Artist(name: "Artist3",
                         playcount: 0,
                         urlString: "",
                         imageURLString: nil,
                         needsTagsUpdate: false,
                         tags: [],
                         topTags: [])
    let artists = [artist1, artist2]

    let tracks = [Track(artist: artist1), Track(artist: artist1), Track(artist: artist3)]

    waitUntil { done in
      self.realmService.save(artists).then { _ -> Promise<Void> in
        let recentTracksProcessor = RecentTracksProcessor()
        return recentTracksProcessor.process(tracks: tracks, using: self.realmService)
      }.done { _ in
        let artists = self.realmService.objects(Artist.self)
        expect(artists.count).to(equal(3))
        expect(artists[0].playcount).to(equal(3))
        expect(artists[1].playcount).to(equal(1))
        expect(artists[2].playcount).to(equal(1))
        done()
      }.noError()
    }
  }
}
