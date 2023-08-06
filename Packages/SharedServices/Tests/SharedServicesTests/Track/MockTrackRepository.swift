//
//  MockTrackRepository.swift
//  MementoFM
//
//  Created by Daniel on 26/10/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine
@testable import TransientModels
@testable import SharedServices

final class MockTrackRepository: TrackRepository {
    var totalPages = 0
    var shouldFailWithError = false
    var trackProvider: (() -> [Track])!

    func getRecentTracksPage(withIndex index: Int,
                             for user: String,
                             from: TimeInterval,
                             limit: Int) -> AnyPublisher<RecentTracksPageResponse, Error> {
        if shouldFailWithError {
            return Fail(error: NSError(domain: "MementoFM", code: 1, userInfo: nil)).eraseToAnyPublisher()
        } else {
            let tracks = trackProvider()
            let recentTracksPage = RecentTracksPage(index: index, totalPages: totalPages, tracks: tracks)
            let response = RecentTracksPageResponse(recentTracksPage: recentTracksPage)
            return Just(response)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
}
