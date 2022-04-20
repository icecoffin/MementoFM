//
//  MockTrackService.swift
//  MementoFM
//
//  Created by Daniel on 22/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import Combine

class MockTrackService: TrackServiceProtocol {
    var customRecentTracks: [Track] = []
    var user: String = ""
    var from: TimeInterval = 0
    var limit: Int = 0
    var didCallGetRecentTracks = false
    var customRecentTracksPages: [RecentTracksPage] = []
    func getRecentTracks(for user: String, from: TimeInterval, limit: Int) -> AnyPublisher<RecentTracksPage, Error> {
        self.user = user
        self.from = from
        self.limit = limit
        didCallGetRecentTracks = true
        return Publishers.Sequence(sequence: customRecentTracksPages).eraseToAnyPublisher()
    }

    var tracks: [Track] = []
    var didCallProcessTracks = false
    func processTracks(_ tracks: [Track], using processor: RecentTracksProcessing) -> AnyPublisher<Void, Error> {
        self.tracks = tracks
        didCallProcessTracks = true
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
