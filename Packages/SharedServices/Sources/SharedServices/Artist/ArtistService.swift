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
import NetworkingInterface
import TransientModels
import SharedServicesInterface
import PersistenceInterface

public final class ArtistService: ArtistServiceProtocol {
    // MARK: - Private properties

    private let persistentStore: PersistentStore
    private let repository: ArtistRepository
    private let topTagsCalculator: ArtistTopTagsCalculating
    private let mainScheduler: AnySchedulerOf<DispatchQueue>
    private let backgroundScheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Init

    public convenience init(
        persistentStore: PersistentStore,
        networkService: NetworkService
    ) {
        self.init(
            persistentStore: persistentStore,
            repository: ArtistNetworkRepository(networkService: networkService),
            topTagsCalculator: ArtistTopTagsCalculator(),
            mainScheduler: DispatchQueue.main.eraseToAnyScheduler(),
            backgroundScheduler: DispatchQueue.global().eraseToAnyScheduler()
        )
    }

    init(
        persistentStore: PersistentStore,
        repository: ArtistRepository,
        topTagsCalculator: ArtistTopTagsCalculating,
        mainScheduler: AnySchedulerOf<DispatchQueue>,
        backgroundScheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.persistentStore = persistentStore
        self.repository = repository
        self.topTagsCalculator = topTagsCalculator
        self.mainScheduler = mainScheduler
        self.backgroundScheduler = backgroundScheduler
    }

    // MARK: - Public properties

    public func getLibrary(for user: String, limit: Int) -> AnyPublisher<LibraryPage, Error> {
        let initialIndex = 1
        let firstPage = repository
            .getLibraryPage(withIndex: initialIndex, for: user, limit: limit)
            .map { $0.libraryPage }

        let otherPages = firstPage.flatMap { libraryPage -> AnyPublisher<LibraryPage, Error> in
            if libraryPage.totalPages <= initialIndex {
                return Empty()
                    .eraseToAnyPublisher()
            }

            let publishers = (initialIndex+1...libraryPage.totalPages).map { index in
                return self.repository.getLibraryPage(withIndex: index, for: user, limit: limit)
                    .map { $0.libraryPage }
                    .eraseToAnyPublisher()
            }
            return Publishers.Sequence(sequence: publishers)
                .flatMap(maxPublishers: .max(5)) { $0 }
                .eraseToAnyPublisher()
        }

        return Publishers.Merge(firstPage, otherPages).eraseToAnyPublisher()
    }

    public func saveArtists(_ artists: [Artist]) -> AnyPublisher<Void, Error> {
        return persistentStore.save(artists)
    }

    public func artistsNeedingTagsUpdate() -> [Artist] {
        let predicate = NSPredicate(format: "needsTagsUpdate == \(true)")
        return persistentStore.objects(Artist.self, filteredBy: predicate)
    }

    public func artistsWithIntersectingTopTags(for artist: Artist) -> [Artist] {
        let topTagNames = artist.topTags.map({ $0.name })
        let predicate = NSPredicate(format: "ANY topTags.name IN %@ AND name != %@", topTagNames, artist.name)
        return self.persistentStore.objects(Artist.self, filteredBy: predicate)
    }

    public func updateArtist(_ artist: Artist, with tags: [Tag]) -> AnyPublisher<Artist, Error> {
        let updatedArtist = artist.updatingTags(to: tags, needsTagsUpdate: false)
        return self.persistentStore.save(updatedArtist)
            .map { _ in
                return updatedArtist
            }
            .eraseToAnyPublisher()
    }

    public func calculateTopTagsForAllArtists(ignoredTags: [IgnoredTag]) -> AnyPublisher<Void, Error> {
        return Future<[Artist], Error> { promise in
            self.backgroundScheduler.schedule {
                let artists = self.persistentStore.objects(Artist.self)
                let updatedArtists = artists.map {
                    return self.topTagsCalculator.calculateTopTags(for: $0, ignoredTags: ignoredTags)
                }
                promise(.success(updatedArtists))
            }
        }
        .flatMap { artists in
            return self.persistentStore.save(artists)
        }
        .receive(on: mainScheduler)
        .eraseToAnyPublisher()
    }

    public func calculateTopTags(for artist: Artist, ignoredTags: [IgnoredTag]) -> AnyPublisher<Void, Error> {
        let updatedArtist = topTagsCalculator.calculateTopTags(for: artist, ignoredTags: ignoredTags)
        return persistentStore.save(updatedArtist)
    }

    public func artists(
        filteredUsing predicate: NSPredicate? = nil,
        sortedBy sortDescriptors: [NSSortDescriptor]
    ) -> AnyPersistentMappedCollection<Artist> {
        return persistentStore.mappedCollection(filteredUsing: predicate, sortedBy: sortDescriptors)
    }

    public func getSimilarArtists(for artist: Artist, limit: Int) -> AnyPublisher<[Artist], Error> {
        return repository.getSimilarArtists(for: artist, limit: limit)
            .map { response -> [Artist] in
                let artistNames = response.similarArtistList.similarArtists.map({ $0.name })
                let predicate = NSPredicate(format: "name in %@", artistNames)
                let artists = self.persistentStore.objects(Artist.self, filteredBy: predicate)
                return artists
            }
            .eraseToAnyPublisher()
    }
}
