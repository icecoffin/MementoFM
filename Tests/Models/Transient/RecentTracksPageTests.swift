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
    private func sampleRecentTracksPage() -> RecentTracksPage? {
        guard let json = Utils.json(forResource: "sample_recent_tracks_page", withExtension: "json") as? NSDictionary else {
            return nil
        }

        let mapper = Mapper(JSON: json)
        return try? RecentTracksPage(map: mapper)
    }

    func testInitializingWithMapper() {
        let recentTracksPage = sampleRecentTracksPage()
        expect(recentTracksPage?.index).to(equal(2))
        expect(recentTracksPage?.totalPages).to(equal(75698))
        expect(recentTracksPage?.tracks.count).to(equal(2))
    }
}
