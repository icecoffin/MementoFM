//
//  MockArtistService.swift
//  MementoFM
//
//  Created by Daniel on 11/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import Combine

class MockArtistService: ArtistServiceProtocol {
    var user: String = ""
    var limit: Int = 0
    var getLibraryShouldReturnError = false
    var didRequestLibrary = false
    var customLibraryPages: [LibraryPage] = []
    func getLibrary(for user: String, limit: Int) -> AnyPublisher<LibraryPage, Error> {
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

    var savingArtists = [Artist]()
    var didCallSaveArtists = false
    func saveArtists(_ artists: [Artist]) -> AnyPublisher<Void, Error> {
        savingArtists = artists
        didCallSaveArtists = true
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    var customArtistsNeedingTagsUpdate: [Artist] = []
    var didRequestArtistsNeedingTagsUpdate = false
    func artistsNeedingTagsUpdate() -> [Artist] {
        didRequestArtistsNeedingTagsUpdate = true
        return customArtistsNeedingTagsUpdate
    }

    var intersectingTopTagsArtist: Artist?
    var customArtistsWithIntersectingTopTags: [Artist] = []
    func artistsWithIntersectingTopTags(for artist: Artist) -> [Artist] {
        intersectingTopTagsArtist = artist
        return customArtistsWithIntersectingTopTags
    }

    var updatingArtist: Artist?
    var updatingTags: [Tag] = []
    var updateArtistShouldReturnError: Bool = false
    var didCallUpdateArtist: Bool = false
    func updateArtist(_ artist: Artist, with tags: [Tag]) -> AnyPublisher<Artist, Error> {
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

    var didCallCalculateTopTagsForAllArtists: Bool = false
    var calculateTopTagsForAllShouldReturnError: Bool = false
    func calculateTopTagsForAllArtists(using calculator: ArtistTopTagsCalculating) -> AnyPublisher<Void, Error> {
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

    var customCalculateTopTagsArtist: Artist?
    var calculateTopTagsShouldReturnError: Bool = false
    var didCallCalculateTopTags: Bool = false
    func calculateTopTags(for artist: Artist, using calculator: ArtistTopTagsCalculating) -> AnyPublisher<Void, Error> {
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

    var customMappedCollection: AnyPersistentMappedCollection<Artist>!
    var artistsParameters: (predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor])?
    func artists(filteredUsing predicate: NSPredicate?,
                 sortedBy sortDescriptors: [NSSortDescriptor]) -> AnyPersistentMappedCollection<Artist> {
        artistsParameters = (predicate: predicate, sortDescriptors: sortDescriptors)
        return customMappedCollection
    }

    var expectedSimilarArtistsArtist: Artist?
    var expectedSimilarArtistsLimit: Int = 0
    var getSimilarArtistsShouldReturnError: Bool = false
    var customSimilarArtists: [Artist] = []
    func getSimilarArtists(for artist: Artist, limit: Int) -> AnyPublisher<[Artist], Error> {
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
