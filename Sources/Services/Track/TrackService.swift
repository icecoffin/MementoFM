//
//  TrackService.swift
//  MementoFM
//
//  Created by Daniel on 07/09/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

// MARK: - TrackServiceProtocol

protocol TrackServiceProtocol: AnyObject {
    func getRecentTracks(for user: String, from: TimeInterval, limit: Int, progress: ((Progress) -> Void)?) -> Promise<[Track]>
    func processTracks(_ tracks: [Track], using processor: RecentTracksProcessing) -> Promise<Void>
}

extension TrackServiceProtocol {
    func getRecentTracks(for user: String, from: TimeInterval, progress: ((Progress) -> Void)?) -> Promise<[Track]> {
        return getRecentTracks(for: user, from: from, limit: 200, progress: progress)
    }

    func processTracks(_ tracks: [Track]) -> Promise<Void> {
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

    func getRecentTracks(for user: String,
                         from: TimeInterval,
                         limit: Int = 200,
                         progress: ((Progress) -> Void)? = nil) -> Promise<[Track]> {
        return Promise { seal in
            let initialIndex = 1
            repository.getRecentTracksPage(withIndex: initialIndex, for: user,
                                           from: from, limit: limit).done { response in
                                            let page = response.recentTracksPage
                                            if page.totalPages <= initialIndex {
                                                seal.fulfill(page.tracks)
                                                return
                                            }

                                            let totalProgress = Progress(totalUnitCount: Int64(page.totalPages - 1))
                                            let pagePromises = (initialIndex+1...page.totalPages).map { index in
                                                return self.repository.getRecentTracksPage(withIndex: index,
                                                                                           for: user,
                                                                                           from: from,
                                                                                           limit: limit).ensure {
                                                    totalProgress.completedUnitCount += 1
                                                    progress?(totalProgress)
                                                }
                                            }

                                            when(fulfilled: pagePromises).done { pageResponses in
                                                let pages = pageResponses.map({ $0.recentTracksPage })
                                                let tracks = ([page] + pages).flatMap({ $0.tracks })
                                                seal.fulfill(tracks)
                                            }.catch { error in
                                                if !error.isCancelled {
                                                    seal.reject(error)
                                                }
                                            }
            }.catch { error in
                if !error.isCancelled {
                    seal.reject(error)
                }
            }
        }
    }

    func processTracks(_ tracks: [Track], using processor: RecentTracksProcessing = RecentTracksProcessor()) -> Promise<Void> {
        return processor.process(tracks: tracks, using: persistentStore)
    }
}
