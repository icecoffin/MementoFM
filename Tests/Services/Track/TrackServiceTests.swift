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
    func test_getRecentTracks_finishesWithSuccess() async throws {
        let totalPages = 5
        let limit = 20

        let trackRepository = MockTrackRepository()
        trackRepository.totalPages = totalPages
        trackRepository.trackProvider = { ModelFactory.generateTracks(inAmount: limit) }
        let trackService = TrackService(repository: trackRepository)

        let recentTracksPages = try await trackService.getRecentTracks(
            for: "User",
            from: 0,
            limit: limit
        ).collect()

        XCTAssertEqual(recentTracksPages.count, totalPages)
    }

    func test_getRecentTracks_failsWithError() async throws {
        let totalPages = 5
        let limit = 20

        let trackRepository = MockTrackRepository()
        trackRepository.totalPages = totalPages
        trackRepository.shouldFailWithError = true
        let trackService = TrackService(repository: trackRepository)

        do {
            _ = try await trackService.getRecentTracks(for: "User", from: 0, limit: limit).collect()
            XCTFail("Expected to receive an error")
        } catch {
            // Success
        }
    }
}
