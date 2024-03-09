//
//  TrackServiceTests.swift
//  MementoFM
//
//  Created by Daniel on 26/10/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest

@testable import MementoFM
import Combine

private final class MockRecentTracksProcessor: RecentTracksProcessing {
    var didCallProcess = false

    func process(tracks: [Track], using persistentStore: PersistentStore) -> AnyPublisher<Void, Error> {
        didCallProcess = true
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

final class TrackServiceTests: XCTestCase {
    private var persistentStore: MockPersistentStore!

    override func setUp() {
        super.setUp()

        persistentStore = MockPersistentStore()
    }

    override func tearDown() {
        persistentStore = nil

        super.tearDown()
    }

    func test_getRecentTracks_finishesWithSuccess() {
        let totalPages = 5
        let limit = 20

        let trackRepository = MockTrackRepository()
        trackRepository.totalPages = totalPages
        trackRepository.trackProvider = { ModelFactory.generateTracks(inAmount: limit) }
        let trackService = TrackService(persistentStore: persistentStore, repository: trackRepository)

        var recentTracksPages: [RecentTracksPage] = []
        _ = trackService.getRecentTracks(for: "User", from: 0, limit: limit)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure:
                    XCTFail("Unexpected failure")
                }
            }, receiveValue: { recentTracksPage in
                recentTracksPages.append(recentTracksPage)
            })

        XCTAssertEqual(recentTracksPages.count, totalPages)
    }

    func test_getRecentTracks_failsWithError() {
        let totalPages = 5
        let limit = 20

        let trackRepository = MockTrackRepository()
        trackRepository.totalPages = totalPages
        trackRepository.shouldFailWithError = true
        let trackService = TrackService(persistentStore: persistentStore, repository: trackRepository)

        var didReceiveError = false
        _ = trackService.getRecentTracks(for: "User", from: 0, limit: limit)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("Expected to receive an error")
                case .failure:
                    didReceiveError = true
                }
            }, receiveValue: { _ in
                XCTFail("Expected to receive an error")
            })

        XCTAssertTrue(didReceiveError)
    }

    func test_processTracks_callsRecentTracksProcessor() {
        let trackService = TrackService(persistentStore: persistentStore, repository: MockTrackRepository())
        let processor = MockRecentTracksProcessor()

        _ = trackService.processTracks([], using: processor)

        XCTAssertTrue(processor.didCallProcess)
    }
}
