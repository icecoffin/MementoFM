//
//  RecentTracksPageTests.swift
//  MementoFMTests
//
//  Created by Daniel on 06/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Mapper
import Nimble

class RecentTracksPageTests: XCTestCase {
    func test_initWithMap_setsCorrectProperties() {
        let recentTracksPage = makeSampleRecentTracksPage()

        expect(recentTracksPage?.index) == 2
        expect(recentTracksPage?.totalPages) == 75698
        expect(recentTracksPage?.tracks.count) == 2
    }

    private func makeSampleRecentTracksPage() -> RecentTracksPage? {
        guard let data = Utils.data(fromResource: "sample_recent_tracks_page", withExtension: "json") else {
            return nil
        }

        let jsonDecoder = JSONDecoder()
        return try? jsonDecoder.decode(RecentTracksPage.self, from: data)
    }
}
