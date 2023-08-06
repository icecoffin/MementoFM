//
//  MockArtistService.swift
//  MementoFM
//
//  Created by Daniel on 11/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine
import TransientModels
import PersistenceInterface
import SharedServicesInterface

public final class MockArtistService: ArtistServiceProtocol {
    public init() { }

    public var user: String = ""
    public var limit: Int = 0
    public var getLibraryShouldReturnError = false
    public var didRequestLibrary = false
    public var customLibraryPages: [LibraryPage] = []
    public func getLibrary(for user: String, limit: Int) -> AnyPublisher<LibraryPage, Error> {
        self.user = user
        self.limit = limit
        didRequestLibrary = true
        if getLibraryShouldReturnError {
            return Fail(error: NSError(domain: "MementoFM", code: 6, userInfo: nil))
                .eraseToAnyPublisher()
        } else {
            return Publishers.Sequence(sequence: customLibraryPages)
                .eraseToAnyPublisher()
        }
    }

    public var savingArtists = [Artist]()
    public var didCallSaveArtists = false
    public func saveArtists(_ artists: [Artist]) -> AnyPublisher<Void, Error> {
        savingArtists = artists
        didCallSaveArtists = true
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    public var customArtistsNeedingTagsUpdate: [Artist] = []
    public var didRequestArtistsNeedingTagsUpdate = false
    public func artistsNeedingTagsUpdate() -> [Artist] {
        didRequestArtistsNeedingTagsUpdate = true
        return customArtistsNeedingTagsUpdate
    }

    public var intersectingTopTagsArtist: Artist?
    public var customArtistsWithIntersectingTopTags: [Artist] = []
    public func artistsWithIntersectingTopTags(for artist: Artist) -> [Artist] {
        intersectingTopTagsArtist = artist
        return customArtistsWithIntersectingTopTags
    }

    public var updatingArtist: Artist?
    public var updatingTags: [Tag] = []
    public var updateArtistShouldReturnError: Bool = false
    public var didCallUpdateArtist: Bool = false
    public func updateArtist(_ artist: Artist, with tags: [Tag]) -> AnyPublisher<Artist, Error> {
        updatingArtist = artist
        updatingTags = tags
        didCallUpdateArtist = true
        if updateArtistShouldReturnError {
            return Fail(error: NSError(domain: "MementoFM", code: 6, userInfo: nil))
                .eraseToAnyPublisher()
        } else {
            return Just(artist)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }

    public var didCallCalculateTopTagsForAllArtists: Bool = false
    public var calculateTopTagsForAllShouldReturnError: Bool = false
    public func calculateTopTagsForAllArtists(ignoredTags: [IgnoredTag]) -> AnyPublisher<Void, Error> {
        didCallCalculateTopTagsForAllArtists = true
        if calculateTopTagsShouldReturnError {
            return Fail(error: NSError(domain: "MementoFM", code: 6, userInfo: nil))
                .eraseToAnyPublisher()
        } else {
            return Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }

    public var customCalculateTopTagsArtist: Artist?
    public var calculateTopTagsShouldReturnError: Bool = false
    public var didCallCalculateTopTags: Bool = false
    public func calculateTopTags(for artist: Artist, ignoredTags: [IgnoredTag]) -> AnyPublisher<Void, Error> {
        customCalculateTopTagsArtist = artist
        didCallCalculateTopTags = true
        if calculateTopTagsShouldReturnError {
            return Fail(error: NSError(domain: "MementoFM", code: 6, userInfo: nil))
                .eraseToAnyPublisher()
        } else {
            return Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }

    public var customMappedCollection: AnyPersistentMappedCollection<Artist>!
    public var artistsParameters: (predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor])?
    public func artists(
        filteredUsing predicate: NSPredicate?,
        sortedBy sortDescriptors: [NSSortDescriptor]
    ) -> AnyPersistentMappedCollection<Artist> {
        artistsParameters = (predicate: predicate, sortDescriptors: sortDescriptors)
        return customMappedCollection
    }

    public var expectedSimilarArtistsArtist: Artist?
    public var expectedSimilarArtistsLimit: Int = 0
    public var getSimilarArtistsShouldReturnError: Bool = false
    public var customSimilarArtists: [Artist] = []
    public func getSimilarArtists(for artist: Artist, limit: Int) -> AnyPublisher<[Artist], Error> {
        expectedSimilarArtistsArtist = artist
        expectedSimilarArtistsLimit = limit
        if getSimilarArtistsShouldReturnError {
            return Fail(error: NSError(domain: "MementoFM", code: 6, userInfo: nil))
                .eraseToAnyPublisher()
        } else {
            return Just(customSimilarArtists)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
}
