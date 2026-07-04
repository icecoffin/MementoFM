//
//  TagService.swift
//  MementoFM
//
//  Created by Daniel on 10/08/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine

// MARK: - TopTagsPage

struct TopTagsPage {
    let artist: Artist
    let topTagsList: TopTagsList
}

// MARK: - TagServiceProtocol

protocol TagServiceProtocol: AnyObject {
    func getTopTags(for artists: [Artist]) -> AsyncThrowingStream<TopTagsPage, Error>
    func getAllTopTags() -> [Tag]
}

// MARK: - TagService

final class TagService: TagServiceProtocol {
    // MARK: - Private properties

    private let artistStore: ArtistStore
    private let repository: TagRepository
    private let maxConcurrentRequests = 5

    // MARK: - Init

    init(artistStore: ArtistStore, repository: TagRepository) {
        self.artistStore = artistStore
        self.repository = repository
    }

    // MARK: - Public methods

    func getTopTags(for artists: [Artist]) -> AsyncThrowingStream<TopTagsPage, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    try await withThrowingTaskGroup(of: TopTagsPage.self) { group in
                        var iterator = artists.makeIterator()

                        func enqueueNext() {
                            guard let artist = iterator.next() else { return }

                            group.addTask {
                                do {
                                    let response = try await self.repository.getTopTags(for: artist.name)
                                    return TopTagsPage(artist: artist, topTagsList: response.topTagsList)
                                } catch {
                                    if Self.isMissingArtistError(error) {
                                        return TopTagsPage(artist: artist, topTagsList: .empty)
                                    } else {
                                        throw error
                                    }
                                }
                            }
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

    func getAllTopTags() -> [Tag] {
        let artists = artistStore.fetchAll()
        return artists.flatMap { return $0.topTags }
    }

    private static func isMissingArtistError(_ error: Error) -> Bool {
        if let lastFMError = error as? LastFMError,
           lastFMError.message == "The artist you supplied could not be found" {
            return true
        }

        return false
    }
}
