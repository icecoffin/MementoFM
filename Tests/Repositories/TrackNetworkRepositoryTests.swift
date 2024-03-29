//
//  TrackRepositoryTests.swift
//  MementoFM
//
//  Created by Daniel on 06/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM

import Alamofire

final class TrackRepositoryTests: XCTestCase {
    private var networkService: MockNetworkService!
    private var trackRepository: TrackNetworkRepository!

    override func setUp() {
        super.setUp()

        networkService = MockNetworkService()
        trackRepository = TrackNetworkRepository(networkService: networkService)
    }

    override func tearDown() {
        networkService = nil
        trackRepository = nil

        super.tearDown()
    }

    func test_getRecentTracks_callsNetworkServiceWithCorrectParameters() {
        let recentTracksPage = RecentTracksPage(index: 1, totalPages: 1, tracks: [])
        let response = RecentTracksPageResponse(recentTracksPage: recentTracksPage)
        networkService.customResponse = response

        _ = trackRepository
            .getRecentTracksPage(withIndex: 1, for: "User", from: TimeInterval(1509982044), limit: 10)

        let expectedParameters: [String: AnyHashable] = ["method": "user.getrecenttracks",
                                                         "api_key": Keys.LastFM.apiKey,
                                                         "user": "User",
                                                         "from": TimeInterval(1509982044),
                                                         "extended": 1,
                                                         "format": "json",
                                                         "page": 1,
                                                         "limit": 10]

        let performRequestParameters = networkService.performRequestParameters
        XCTAssertEqual(performRequestParameters?.method, .get)
        XCTAssertEqual(performRequestParameters?.parameters as? [String: AnyHashable], expectedParameters)
        XCTAssertTrue(performRequestParameters?.encoding is URLEncoding)
        XCTAssertNil(performRequestParameters?.headers)
    }
}
