//
//  MockTrackService.swift
//  MementoFM
//
//  Created by Daniel on 22/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine
import TransientModels
import SharedServicesInterface

public final class MockTrackService: TrackServiceProtocol {
    public var customRecentTracks: [Track] = []
    public var user: String = ""
    public var from: TimeInterval = 0
    public var limit: Int = 0
    public var didCallGetRecentTracks = false
    public var customRecentTracksPages: [RecentTracksPage] = []
    public func getRecentTracks(for user: String, from: TimeInterval, limit: Int) -> AnyPublisher<RecentTracksPage, Error> {
        self.user = user
        self.from = from
        self.limit = limit
        didCallGetRecentTracks = true
        return Publishers.Sequence(sequence: customRecentTracksPages).eraseToAnyPublisher()
    }

    public var tracks: [Track] = []
    public var didCallProcessTracks = false
    public func processTracks(_ tracks: [Track], using processor: RecentTracksProcessing) -> AnyPublisher<Void, Error> {
        self.tracks = tracks
        didCallProcessTracks = true
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
