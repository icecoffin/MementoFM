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

final class TrackServiceTests: XCTestCase {
    func test_getRecentTracks_finishesWithSuccess() {
        let totalPages = 5
        let limit = 20

        let trackRepository = MockTrackRepository()
        trackRepository.totalPages = totalPages
        trackRepository.trackProvider = { ModelFactory.generateTracks(inAmount: limit) }
        let trackService = TrackService(repository: trackRepository)

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
        let trackService = TrackService(repository: trackRepository)

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
}
