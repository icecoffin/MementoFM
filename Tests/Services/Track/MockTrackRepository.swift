//
//  MockTrackRepository.swift
//  MementoFM
//
//  Created by Daniel on 26/10/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import PromiseKit

class MockTrackRepository: TrackRepository {
    var totalPages = 0
    var shouldFailWithError = false
    var trackProvider: (() -> [Track])!

    func getRecentTracksPage(withIndex index: Int,
                             for user: String,
                             from: TimeInterval,
                             limit: Int) -> Promise<RecentTracksPageResponse> {
        if shouldFailWithError {
            return Promise(error: NSError(domain: "MementoFM", code: 1, userInfo: nil))
        } else {
            let tracks = trackProvider()
            let recentTracksPage = RecentTracksPage(index: index, totalPages: totalPages, tracks: tracks)
            let response = RecentTracksPageResponse(recentTracksPage: recentTracksPage)
            return .value(response)
        }
    }
}
