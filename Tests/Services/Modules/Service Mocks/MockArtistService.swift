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

final class MockArtistService: ArtistServiceProtocol {
    var user: String = ""
    var limit: Int = 0
    var getLibraryShouldReturnError = false
    var didRequestLibrary = false
    var customLibraryPages: [LibraryPage] = []
    func getLibrary(for user: String, limit: Int) -> AsyncThrowingStream<LibraryPage, any Error> {
        self.user = user
        self.limit = limit
        didRequestLibrary = true
        if getLibraryShouldReturnError {
            return AsyncThrowingStream(error: NSError(domain: "MementoFM", code: 6, userInfo: nil))
        } else {
            return AsyncThrowingStream(elements: customLibraryPages)
        }
    }

    var savingArtists = [Artist]()
    var didCallSaveArtists = false
    func saveArtists(_ artists: [Artist]) async throws {
        savingArtists = artists
        didCallSaveArtists = true
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
    func updateArtist(_ artist: Artist, with tags: [Tag]) async throws -> Artist {
        updatingArtist = artist
        updatingTags = tags
        didCallUpdateArtist = true
        if updateArtistShouldReturnError {
            throw NSError(domain: "MementoFM", code: 6, userInfo: nil)
        } else {
            return artist
        }
    }

    var didCallCalculateTopTagsForAllArtists: Bool = false
    var calculateTopTagsForAllShouldReturnError: Bool = false
    func calculateTopTagsForAllArtists(using calculator: any ArtistTopTagsCalculating) async throws {
        didCallCalculateTopTagsForAllArtists = true
        if calculateTopTagsShouldReturnError {
            throw NSError(domain: "MementoFM", code: 6, userInfo: nil)
        } else {
            return
        }
    }

    var customCalculateTopTagsArtist: Artist?
    var calculateTopTagsShouldReturnError: Bool = false
    var didCallCalculateTopTags: Bool = false
    func calculateTopTags(for artist: Artist, using calculator: any ArtistTopTagsCalculating) async throws {
        customCalculateTopTagsArtist = artist
        didCallCalculateTopTags = true
        if calculateTopTagsShouldReturnError {
            throw NSError(domain: "MementoFM", code: 6, userInfo: nil)
        } else {
            return
        }
    }

    var customMappedCollection: AnyPersistentMappedCollection<Artist>!
    var artistsParameters: (predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor])?
    func artists(
        filteredUsing predicate: NSPredicate?,
        sortedBy sortDescriptors: [NSSortDescriptor]
    ) -> AnyPersistentMappedCollection<Artist> {
        artistsParameters = (predicate: predicate, sortDescriptors: sortDescriptors)
        return customMappedCollection
    }

    var expectedSimilarArtistsArtist: Artist?
    var expectedSimilarArtistsLimit: Int = 0
    var getSimilarArtistsShouldReturnError: Bool = false
    var customSimilarArtists: [Artist] = []
    func getSimilarArtists(for artist: Artist, limit: Int) async throws -> [Artist] {
        expectedSimilarArtistsArtist = artist
        expectedSimilarArtistsLimit = limit
        if getSimilarArtistsShouldReturnError {
            throw NSError(domain: "MementoFM", code: 6, userInfo: nil)
        } else {
            return customSimilarArtists
        }
    }
}
