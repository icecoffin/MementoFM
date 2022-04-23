//
//  RecentTracksPageTests.swift
//  MementoFMTests
//
//  Created by Daniel on 06/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble

final class RecentTracksPageTests: XCTestCase {
    func test_decodeFromJSON_setsCorrectProperties_forMultiTrackPage() {
        let recentTracksPage = makeMultipleRecentTracksPage()

        expect(recentTracksPage?.index) == 2
        expect(recentTracksPage?.totalPages) == 75698
        expect(recentTracksPage?.tracks.count) == 2
    }

    func test_decodeFromJSON_setsCorrectProperties_forSingleTrackPage() {
        let recentTracksPage = makeSingleRecentTrackPage()

        expect(recentTracksPage?.index) == 2
        expect(recentTracksPage?.totalPages) == 75698
        expect(recentTracksPage?.tracks.count) == 1
    }

    // MARK: - Helpers

    private func makeSingleRecentTrackPage() -> RecentTracksPage? {
        return makeSampleRecentTracksPage(fileName: "sample_single_recent_track_page")
    }

    private func makeMultipleRecentTracksPage() -> RecentTracksPage? {
        return makeSampleRecentTracksPage(fileName: "sample_recent_tracks_page")
    }

    private func makeSampleRecentTracksPage(fileName: String) -> RecentTracksPage? {
        guard let data = Utils.data(fromResource: fileName, withExtension: "json") else {
            return nil
        }

        let jsonDecoder = JSONDecoder()
        return try? jsonDecoder.decode(RecentTracksPage.self, from: data)
    }
}
