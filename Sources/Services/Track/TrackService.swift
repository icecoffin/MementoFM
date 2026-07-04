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
    func getRecentTracks(
        for user: String,
        from: TimeInterval,
        limit: Int
    ) -> AsyncThrowingStream<RecentTracksPage, Error>
}

extension TrackServiceProtocol {
    func getRecentTracks(for user: String, from: TimeInterval) -> AsyncThrowingStream<RecentTracksPage, Error> {
        return getRecentTracks(for: user, from: from, limit: 200)
    }
}

// MARK: - TrackService

final class TrackService: TrackServiceProtocol {
    // MARK: - Private properties

    private let repository: TrackRepository
    private let maxConcurrentRequests = 5

    // MARK: - Init

    init(repository: TrackRepository) {
        self.repository = repository
    }

    // MARK: - Public methods

    func getRecentTracks(
        for user: String,
        from: TimeInterval,
        limit: Int
    ) -> AsyncThrowingStream<RecentTracksPage, Error> {
        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    var nextIndex = 1

                    let firstPage = try await self.repository.getRecentTracksPage(
                        withIndex: nextIndex,
                        for: user,
                        from: from,
                        limit: limit
                    ).recentTracksPage

                    continuation.yield(firstPage)

                    guard firstPage.totalPages > nextIndex else {
                        continuation.finish()
                        return
                    }

                    nextIndex += 1

                    try await withThrowingTaskGroup(of: RecentTracksPage.self) { group in
                        func enqueueNext() {
                            guard nextIndex <= firstPage.totalPages else { return }

                            let index = nextIndex
                            group.addTask {
                                try await self.repository.getRecentTracksPage(
                                    withIndex: index,
                                    for: user,
                                    from: from,
                                    limit: limit
                                ).recentTracksPage
                            }

                            nextIndex += 1
                        }

                        for _ in 0..<maxConcurrentRequests {
                            enqueueNext()
                        }

                        while let page = try await group.next() {
                            continuation.yield(page)
                            enqueueNext()
                        }
                    }

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
