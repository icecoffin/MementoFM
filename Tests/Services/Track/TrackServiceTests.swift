//
//  TrackServiceTests.swift
//  MementoFM
//
//  Created by Daniel on 26/10/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
import Nimble
@testable import MementoFM
import PromiseKit

class RecentTracksStubProcessor: RecentTracksProcessing {
  var didCallProcess = false

  func process(tracks: [Track], using realmService: PersistentStore) -> Promise<Void> {
    didCallProcess = true
    return .value(())
  }
}

class TrackServiceTests: XCTestCase {
  var realmService: RealmService!

  override func setUp() {
    super.setUp()

    realmService = RealmService(getRealm: {
      return RealmFactory.inMemoryRealm()
    })
  }

  override func tearDown() {
    realmService = nil
    super.tearDown()
  }

  func testGettingRecentTracksWithSuccess() {
    let totalPages = 5
    let limit = 20

    let trackRepository = TrackStubRepository(totalPages: totalPages, shouldFailWithError: false, trackProvider: {
      ModelFactory.generateTracks(inAmount: limit)
    })
    let trackService = TrackService(persistentStore: realmService, repository: trackRepository)

    var progressCallCount = 0
    waitUntil { done in
      trackService.getRecentTracks(for: "User", from: 0, limit: limit) { _ in
        progressCallCount += 1
      }.done { tracks in
        expect(progressCallCount).to(equal(totalPages - 1))

        let expectedTracks = (0..<totalPages).flatMap { _ in ModelFactory.generateTracks(inAmount: limit) }
        expect(expectedTracks).to(equal(tracks))
        done()
      }.catch { _ in
        fail()
      }
    }
  }

  func testGettingRecentTracksWithError() {
    let totalPages = 5
    let limit = 20

    let trackRepository = TrackStubRepository(totalPages: totalPages, shouldFailWithError: true, trackProvider: { [] })
    let trackService = TrackService(persistentStore: realmService, repository: trackRepository)

    waitUntil { done in
      trackService.getRecentTracks(for: "User", from: 0, limit: limit).done { _ in
        fail()
      }.catch { error in
        expect(error).toNot(beNil())
        done()
      }
    }
  }

  func testProcessingTracks() {
    let trackService = TrackService(persistentStore: realmService, repository: TrackEmptyStubRepository())

    let processor = RecentTracksStubProcessor()
    trackService.processTracks([], using: processor).done { _ in
      expect(processor.didCallProcess).to(beTrue())
    }.noError()
  }
}
