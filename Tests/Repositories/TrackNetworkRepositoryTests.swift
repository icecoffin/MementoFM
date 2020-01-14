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
import PromiseKit
import Alamofire

class TrackRepositoryTests: XCTestCase {
    func testGetRecentTracksRequestParametersAreCorrect() {
        let recentTracksPage = RecentTracksPage(index: 1, totalPages: 1, tracks: [])
        let response = RecentTracksPageResponse(recentTracksPage: recentTracksPage)
        let networkService = StubNetworkService(response: response)

        let trackRepository = TrackNetworkRepository(networkService: networkService)
        trackRepository.getRecentTracksPage(withIndex: 1, for: "User", from: TimeInterval(1509982044), limit: 10).done { _ in
            expect(networkService.method).to(equal(.get))
            let expectedParameters: [String: AnyHashable] = ["method": "user.getrecenttracks",
                                                             "api_key": Keys.LastFM.apiKey,
                                                             "user": "User",
                                                             "from": TimeInterval(1509982044),
                                                             "extended": 1,
                                                             "format": "json",
                                                             "page": 1,
                                                             "limit": 10]
            expect(networkService.parameters as? [String: AnyHashable]).to(equal(expectedParameters))
            expect(networkService.encoding).to(beAKindOf(URLEncoding.self))
            expect(networkService.headers).to(beNil())
        }.noError()
    }
}
