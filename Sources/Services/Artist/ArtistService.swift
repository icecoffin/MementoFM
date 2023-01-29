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
import TransientModels
import Persistence

// MARK: - ArtistServiceProtocol

protocol ArtistServiceProtocol: AnyObject {
    func getLibrary(for user: String, limit: Int) -> AnyPublisher<LibraryPage, Error>

    func saveArtists(_ artists: [Artist]) -> AnyPublisher<Void, Error>

    func artistsNeedingTagsUpdate() -> [Artist]
    func artistsWithIntersectingTopTags(for artist: Artist) -> [Artist]

    func updateArtist(_ artist: Artist, with tags: [Tag]) -> AnyPublisher<Artist, Error>

    func calculateTopTagsForAllArtists(using calculator: ArtistTopTagsCalculating) -> AnyPublisher<Void, Error>

    func calculateTopTags(for artist: Artist, using calculator: ArtistTopTagsCalculating) -> AnyPublisher<Void, Error>

    func artists(filteredUsing predicate: NSPredicate?,
                 sortedBy sortDescriptors: [NSSortDescriptor]) -> AnyPersistentMappedCollection<Artist>
    func getSimilarArtists(for artist: Artist, limit: Int) -> AnyPublisher<[Artist], Error>
}

extension ArtistServiceProtocol {
    func getLibrary(for user: String) -> AnyPublisher<LibraryPage, Error> {
        return getLibrary(for: user, limit: 200)
    }

    func artists(sortedBy sortDescriptors: [NSSortDescriptor]) -> AnyPersistentMappedCollection<Artist> {
        return artists(filteredUsing: nil, sortedBy: sortDescriptors)
    }

    func getSimilarArtists(for artist: Artist) -> AnyPublisher<[Artist], Error> {
        return getSimilarArtists(for: artist, limit: 20)
    }
}

// MARK: - ArtistService

final class ArtistService: ArtistServiceProtocol {
    // MARK: - Private properties

    private let persistentStore: PersistentStore
    private let repository: ArtistRepository
    private let mainScheduler: AnySchedulerOf<DispatchQueue>
    private let backgroundScheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Init

    init(persistentStore: PersistentStore,
         repository: ArtistRepository,
         mainScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler(),
         backgroundScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global().eraseToAnyScheduler()) {
        self.persistentStore = persistentStore
        self.repository = repository
        self.mainScheduler = mainScheduler
        self.backgroundScheduler = backgroundScheduler
    }

    // MARK: - Public properties

    func getLibrary(for user: String, limit: Int) -> AnyPublisher<LibraryPage, Error> {
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

    func saveArtists(_ artists: [Artist]) -> AnyPublisher<Void, Error> {
        return persistentStore.save(artists)
    }

    func artistsNeedingTagsUpdate() -> [Artist] {
        let predicate = NSPredicate(format: "needsTagsUpdate == \(true)")
        return persistentStore.objects(Artist.self, filteredBy: predicate)
    }

    func artistsWithIntersectingTopTags(for artist: Artist) -> [Artist] {
        let topTagNames = artist.topTags.map({ $0.name })
        let predicate = NSPredicate(format: "ANY topTags.name IN %@ AND name != %@", topTagNames, artist.name)
        return self.persistentStore.objects(Artist.self, filteredBy: predicate)
    }

    func updateArtist(_ artist: Artist, with tags: [Tag]) -> AnyPublisher<Artist, Error> {
        let updatedArtist = artist.updatingTags(to: tags, needsTagsUpdate: false)
        return self.persistentStore.save(updatedArtist)
            .map { _ in
                return updatedArtist
            }
            .eraseToAnyPublisher()
    }

    func calculateTopTagsForAllArtists(using calculator: ArtistTopTagsCalculating) -> AnyPublisher<Void, Error> {
        return Future<[Artist], Error>() { promise in
            self.backgroundScheduler.schedule {
                let artists = self.persistentStore.objects(Artist.self)
                let updatedArtists = artists.map { return calculator.calculateTopTags(for: $0) }
                promise(.success(updatedArtists))
            }
        }
        .flatMap { artists in
            return self.persistentStore.save(artists)
        }
        .receive(on: mainScheduler)
        .eraseToAnyPublisher()
    }

    func calculateTopTags(for artist: Artist, using calculator: ArtistTopTagsCalculating) -> AnyPublisher<Void, Error> {
        let updatedArtist = calculator.calculateTopTags(for: artist)
        return persistentStore.save(updatedArtist)
    }

    func artists(filteredUsing predicate: NSPredicate? = nil,
                 sortedBy sortDescriptors: [NSSortDescriptor]) -> AnyPersistentMappedCollection<Artist> {
        return persistentStore.mappedCollection(filteredUsing: predicate, sortedBy: sortDescriptors)
    }

    func getSimilarArtists(for artist: Artist, limit: Int) -> AnyPublisher<[Artist], Error> {
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
