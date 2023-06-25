//
//  TrackService.swift
//  MementoFM
//
//  Created by Daniel on 07/09/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine
import Networking
import TransientModels
import PersistenceInterface
import SharedServicesInterface

public final class TrackService: TrackServiceProtocol {
    // MARK: - Private properties

    private let persistentStore: PersistentStore
    private let repository: TrackRepository

    // MARK: - Init

    public convenience init(
        persistentStore: PersistentStore,
        networkService: NetworkService
    ) {
        self.init(
            persistentStore: persistentStore,
            repository: TrackNetworkRepository(networkService: networkService)
        )
    }

    init(
        persistentStore: PersistentStore,
        repository: TrackRepository
    ) {
        self.persistentStore = persistentStore
        self.repository = repository
    }

    // MARK: - Public methods

    public func getRecentTracks(
        for user: String,
        from: TimeInterval,
        limit: Int
    ) -> AnyPublisher<RecentTracksPage, Error> {
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

    public func processTracks(
        _ tracks: [Track],
        using processor: RecentTracksProcessing
    ) -> AnyPublisher<Void, Error> {
        return processor.process(tracks: tracks, using: persistentStore)
    }
}
