//
//  TrackService.swift
//  MementoFM
//
//  Created by Daniel on 07/09/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine

// MARK: - TrackServiceProtocol

protocol TrackServiceProtocol: AnyObject {
    func getRecentTracks(for user: String, from: TimeInterval, limit: Int) -> AnyPublisher<RecentTracksPage, Error>
    func processTracks(_ tracks: [Track], using processor: RecentTracksProcessing) -> AnyPublisher<Void, Error>
}

extension TrackServiceProtocol {
    func getRecentTracks(for user: String, from: TimeInterval) -> AnyPublisher<RecentTracksPage, Error> {
        return getRecentTracks(for: user, from: from, limit: 200)
    }

    func processTracks(_ tracks: [Track]) -> AnyPublisher<Void, Error> {
        return processTracks(tracks, using: RecentTracksProcessor())
    }
}

// MARK: - TrackService

final class TrackService: TrackServiceProtocol {
    // MARK: - Private properties

    private let persistentStore: PersistentStore
    private let repository: TrackRepository

    // MARK: - Init

    init(persistentStore: PersistentStore, repository: TrackRepository) {
        self.persistentStore = persistentStore
        self.repository = repository
    }

    // MARK: - Public methods

    func getRecentTracks(for user: String, from: TimeInterval, limit: Int) -> AnyPublisher<RecentTracksPage, Error> {
        let initialIndex = 1
        let firstPage = repository
            .getRecentTracksPage(withIndex: initialIndex, for: user, from: from, limit: limit)
            .map { $0.recentTracksPage }

        let otherPages = firstPage.flatMap { recentTracksPage -> AnyPublisher<RecentTracksPage, Error> in
            if recentTracksPage.totalPages <= initialIndex {
                return Empty()
                    .eraseToAnyPublisher()
            }

            let publishers = (initialIndex+1...recentTracksPage.totalPages).map { index in
                return self.repository.getRecentTracksPage(withIndex: index, for: user, from: from, limit: limit)
                    .map { $0.recentTracksPage }
                    .eraseToAnyPublisher()
            }
            return Publishers.Sequence(sequence: publishers)
                .flatMap(maxPublishers: .max(5)) { $0 }
                .eraseToAnyPublisher()
        }

        return Publishers.Merge(firstPage, otherPages).eraseToAnyPublisher()
    }

    func processTracks(_ tracks: [Track], using processor: RecentTracksProcessing) -> AnyPublisher<Void, Error> {
        return processor.process(tracks: tracks, using: persistentStore)
    }
}
