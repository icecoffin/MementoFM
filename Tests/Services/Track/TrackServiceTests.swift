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

  func process(tracks: [Track], using realmService: RealmService) -> Promise<Void> {
    didCallProcess = true
    return Promise(value: ())
  }
}

class TrackServiceTests: XCTestCase {
  var realmService: RealmService!

  let totalPages = 5
  let limit = 20

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
    let trackRepository = TrackStubRepository(totalPages: totalPages, shouldFailWithError: false)
    let trackService = TrackService(realmService: realmService, repository: trackRepository)

    var progressCallCount = 0
    waitUntil { done in
      trackService.getRecentTracks(for: "User", from: 0, limit: self.limit) { _ in
        progressCallCount += 1
      }.then { tracks -> Void in
        expect(progressCallCount).to(equal(self.totalPages - 1))

        let expectedTracks = (0..<self.totalPages).flatMap { _ in ModelFactory.generateTracks(inAmount: self.limit) }
        expect(expectedTracks).to(equal(tracks))
        done()
      }.catch { _ in
        fail()
      }
    }
  }

  func testGettingRecentTracksWithError() {
    let trackRepository = TrackStubRepository(totalPages: totalPages, shouldFailWithError: true)
    let trackService = TrackService(realmService: realmService, repository: trackRepository)

    waitUntil { done in
      trackService.getRecentTracks(for: "User", from: 0, limit: self.limit).then { _ in
        fail()
      }.catch { error in
        expect(error).toNot(beNil())
        done()
      }
    }
  }

  func testProcessingTracks() {
    let trackRepository = TrackStubRepository(totalPages: totalPages, shouldFailWithError: false)
    let trackService = TrackService(realmService: realmService, repository: trackRepository)

    let processor = RecentTracksStubProcessor()
    trackService.processTracks([], using: processor).then {
      expect(processor.didCallProcess).to(beTrue())
    }.noError()
  }
}
