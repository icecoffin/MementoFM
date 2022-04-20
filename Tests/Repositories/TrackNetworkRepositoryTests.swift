//
//  TrackRepositoryTests.swift
//  MementoFM
//
//  Created by Daniel on 06/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble
import Alamofire

class TrackRepositoryTests: XCTestCase {
    var networkService: MockNetworkService!
    var trackRepository: TrackNetworkRepository!

    override func setUp() {
        super.setUp()

        networkService = MockNetworkService()
        trackRepository = TrackNetworkRepository(networkService: networkService)
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
        expect(performRequestParameters?.method) == .get
        expect(performRequestParameters?.parameters as? [String: AnyHashable]) == expectedParameters
        expect(performRequestParameters?.encoding).to(beAKindOf(URLEncoding.self))
        expect(performRequestParameters?.headers).to(beNil())
    }
}
