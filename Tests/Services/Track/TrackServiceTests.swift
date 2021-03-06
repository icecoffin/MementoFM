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

class MockRecentTracksProcessor: RecentTracksProcessing {
    var didCallProcess = false

    func process(tracks: [Track], using persistentStore: PersistentStore) -> Promise<Void> {
        didCallProcess = true
        return .value(())
    }
}

class TrackServiceTests: XCTestCase {
    var persistentStore: MockPersistentStore!

    override func setUp() {
        super.setUp()

        persistentStore = MockPersistentStore()
    }

    func test_getRecentTracks_finishesWithSuccess() {
        let totalPages = 5
        let limit = 20

        let trackRepository = MockTrackRepository()
        trackRepository.totalPages = totalPages
        trackRepository.trackProvider = { ModelFactory.generateTracks(inAmount: limit) }
        let trackService = TrackService(persistentStore: persistentStore, repository: trackRepository)

        var progressCallCount = 0
        waitUntil { done in
            trackService.getRecentTracks(for: "User", from: 0, limit: limit) { _ in
                progressCallCount += 1
            }.done { tracks in
                expect(progressCallCount) == totalPages - 1

                let expectedTracks = (0..<totalPages).flatMap { _ in ModelFactory.generateTracks(inAmount: limit) }
                expect(tracks) == expectedTracks
                done()
            }.catch { _ in
                fail()
            }
        }
    }

    func test_getRecentTracks_failsWithError() {
        let totalPages = 5
        let limit = 20

        let trackRepository = MockTrackRepository()
        trackRepository.totalPages = totalPages
        trackRepository.shouldFailWithError = true
        let trackService = TrackService(persistentStore: persistentStore, repository: trackRepository)

        var didReceiveError = false
        trackService.getRecentTracks(for: "User", from: 0, limit: limit).done { _ in
            fail()
        }.catch { _ in
            didReceiveError = true
        }

        expect(didReceiveError).toEventually(beTrue())
    }

    func test_processTracks_callsRecentTracksProcessor() {
        let trackService = TrackService(persistentStore: persistentStore, repository: MockTrackRepository())
        let processor = MockRecentTracksProcessor()

        _ = trackService.processTracks([], using: processor)

        expect(processor.didCallProcess) == true
    }
}
