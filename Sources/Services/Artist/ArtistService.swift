//
//  ArtistService.swift
//  MementoFM
//
//  Created by Daniel on 27/07/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine
import CombineSchedulers

// MARK: - ArtistServiceProtocol

protocol ArtistServiceProtocol: AnyObject {
    func getLibrary(for user: String, limit: Int) -> AsyncThrowingStream<LibraryPage, Error>

    func saveArtists(_ artists: [Artist]) async throws

    func artistsNeedingTagsUpdate() -> [Artist]
    func artistsWithIntersectingTopTags(for artist: Artist) -> [Artist]

    func updateArtist(_ artist: Artist, with tags: [Tag]) async throws -> Artist

    func calculateTopTagsForAllArtists(using calculator: ArtistTopTagsCalculating) async throws

    func calculateTopTags(for artist: Artist, using calculator: ArtistTopTagsCalculating) async throws
    func artists(
        filteredUsing predicate: NSPredicate?,
        sortedBy sortDescriptors: [NSSortDescriptor]
    ) -> AnyPersistentMappedCollection<Artist>

    func getSimilarArtists(for artist: Artist, limit: Int) async throws -> [Artist]
}

extension ArtistServiceProtocol {
    func getLibrary(for user: String) -> AsyncThrowingStream<LibraryPage, Error> {
        getLibrary(for: user, limit: 200)
    }

    func artists(sortedBy sortDescriptors: [NSSortDescriptor]) -> AnyPersistentMappedCollection<Artist> {
        return artists(filteredUsing: nil, sortedBy: sortDescriptors)
    }

    func getSimilarArtists(for artist: Artist) async throws -> [Artist] {
        try await getSimilarArtists(for: artist, limit: 20)
    }
}

// MARK: - ArtistService

final class ArtistService: ArtistServiceProtocol {
    // MARK: - Private properties

    private let artistStore: ArtistStore
    private let repository: ArtistRepository
//    private let mainScheduler: AnySchedulerOf<DispatchQueue>
    private let backgroundScheduler: AnySchedulerOf<DispatchQueue>
    private let maxConcurrentRequests = 5

    // MARK: - Init

    init(
        artistStore: ArtistStore,
        repository: ArtistRepository,
//        mainScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler(),
        backgroundScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global().eraseToAnyScheduler()
    ) {
        self.artistStore = artistStore
        self.repository = repository
//        self.mainScheduler = mainScheduler
        self.backgroundScheduler = backgroundScheduler
    }

    // MARK: - Public methods

    func getLibrary(for user: String, limit: Int) -> AsyncThrowingStream<LibraryPage, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    var nextIndex = 1

                    let firstPage = try await self.repository.getLibraryPage(
                        withIndex: nextIndex,
                        for: user,
                        limit: limit
                    ).libraryPage

                    continuation.yield(firstPage)

                    guard firstPage.totalPages > nextIndex else {
                        continuation.finish()
                        return
                    }

                    nextIndex += 1

                    try await withThrowingTaskGroup(of: LibraryPage.self) { group in
                        func enqueueNext() {
                            guard nextIndex <= firstPage.totalPages else { return }

                            let index = nextIndex

                            group.addTask {
                                try await self.repository.getLibraryPage(
                                    withIndex: index,
                                    for: user,
                                    limit: limit
                                ).libraryPage
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

    func saveArtists(_ artists: [Artist]) async throws {
        try await artistStore.save(artists: artists)
    }

    func artistsNeedingTagsUpdate() -> [Artist] {
        let predicate = NSPredicate(format: "needsTagsUpdate == \(true)")
        return artistStore.fetchAll(filteredBy: predicate)
    }

    func artistsWithIntersectingTopTags(for artist: Artist) -> [Artist] {
        let topTagNames = artist.topTags.map({ $0.name })
        let predicate = NSPredicate(format: "ANY topTags.name IN %@ AND name != %@", topTagNames, artist.name)
        return artistStore.fetchAll(filteredBy: predicate)
    }

    func updateArtist(_ artist: Artist, with tags: [Tag]) async throws -> Artist {
        let updatedArtist = artist.updatingTags(to: tags, needsTagsUpdate: false)
        try await artistStore.save(artist: updatedArtist)
        return updatedArtist
    }

    func calculateTopTagsForAllArtists(using calculator: ArtistTopTagsCalculating) async throws {
        let updatedArtists = await withCheckedContinuation { continuation in
            backgroundScheduler.schedule {
                let artists = self.artistStore.fetchAll()
                let updatedArtists = artists.map { return calculator.calculateTopTags(for: $0) }
                continuation.resume(returning: updatedArtists)
            }
        }

        try await artistStore.save(artists: updatedArtists)
    }

    func calculateTopTags(for artist: Artist, using calculator: ArtistTopTagsCalculating) async throws {
        let updatedArtist = calculator.calculateTopTags(for: artist)
        try await artistStore.save(artist: updatedArtist)
    }

    func artists(
        filteredUsing predicate: NSPredicate? = nil,
        sortedBy sortDescriptors: [NSSortDescriptor]
    ) -> AnyPersistentMappedCollection<Artist> {
        return artistStore.mappedCollection(filteredUsing: predicate, sortedBy: sortDescriptors)
    }

    func getSimilarArtists(for artist: Artist, limit: Int) async throws -> [Artist] {
        let response = try await repository.getSimilarArtists(for: artist, limit: limit)
        let artistNames = response.similarArtistList.similarArtists.map({ $0.name })
        let predicate = NSPredicate(format: "name in %@", artistNames)
        let artists = artistStore.fetchAll(filteredBy: predicate)
        return artists
    }
}
