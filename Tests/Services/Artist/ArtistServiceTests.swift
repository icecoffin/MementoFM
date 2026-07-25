//
//  ArtistServiceTests.swift
//  MementoFM
//
//  Created by Daniel on 03/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM

import CombineSchedulers

final class ArtistServiceTests: XCTestCase {
    private var artistStore: MockArtistStore!
    private var scheduler: AnySchedulerOf<DispatchQueue>!

    override func setUp() {
        super.setUp()

        artistStore = MockArtistStore()
        scheduler = .immediate
    }

    override func tearDown() {
        artistStore = nil
        scheduler = nil

        super.tearDown()
    }

    func test_getLibrary_emitsLibraryPages() async throws {
        let totalPages = 5
        let artistsPerPage = 10

        let repository = MockArtistLibraryRepository(totalPages: totalPages, shouldFailWithError: false, artistProvider: { _ in
            return ModelFactory.generateArtists(inAmount: artistsPerPage)
        })
        let artistService = ArtistService(artistStore: artistStore, repository: repository)

        let libraryPages = try await artistService.getLibrary(for: "user", limit: artistsPerPage).collect()

        XCTAssertEqual(libraryPages.count, totalPages)

        let expectedArtists = (0..<totalPages).flatMap { _ in ModelFactory.generateArtists(inAmount: artistsPerPage) }
        let receivedArtists = libraryPages.map { $0.artists }.flatMap { $0 }
        XCTAssertEqual(receivedArtists, expectedArtists)
    }

    func test_getLibrary_emitsErrorOnFailure() async {
        let totalPages = 5
        let artistsPerPage = 10

        let repository = MockArtistLibraryRepository(
            totalPages: totalPages,
            shouldFailWithError: true,
            artistProvider: { _ in return [] }
        )
        let artistService = ArtistService(artistStore: artistStore, repository: repository)

        do {
            _ = try await artistService.getLibrary(for: "user", limit: artistsPerPage).collect()
            XCTFail("Expected to receive an error")

        } catch {
            // Success
        }
    }

    func test_saveArtists_callsArtistStore() async throws {
        let artistService = ArtistService(artistStore: artistStore, repository: StubArtistEmptyRepository())

        let artists = ModelFactory.generateArtists(inAmount: 5)
        _ = try await artistService.saveArtists(artists)

        XCTAssertEqual(artistStore?.saveParameters, artists)
    }

    func test_artistsNeedingTagsUpdate_callsArtistStoreStoreWithCorrectParameters() {
        let artistService = ArtistService(artistStore: artistStore, repository: StubArtistEmptyRepository())

        _ = artistService.artistsNeedingTagsUpdate()

        XCTAssertEqual(artistStore.fetchAllParameters?.predicateFormat, "needsTagsUpdate == 1")
    }

    func test_artistsWithIntersectingTopTags_callsArtistStoreWithCorrectParameters() {
        let artistService = ArtistService(artistStore: artistStore, repository: StubArtistEmptyRepository())

        let tags = [Tag(name: "Tag1", count: 1),
                    Tag(name: "Tag2", count: 2),
                    Tag(name: "Tag3", count: 3)]
        let artist = ModelFactory.generateArtist(index: 1).updatingTopTags(to: tags)

        _ = artistService.artistsWithIntersectingTopTags(for: artist)

        let predicate = artistStore.fetchAllParameters
        XCTAssertEqual(predicate?.predicateFormat, "ANY topTags.name IN {\"Tag1\", \"Tag2\", \"Tag3\"} AND name != \"\(artist.name)\"")
    }

    func test_updateArtistWithTags_updatesArtist_andCallsArtistStoreWithCorrectParameters() async throws {
        let artistService = ArtistService(artistStore: artistStore, repository: StubArtistEmptyRepository())

        let artist = ModelFactory.generateArtist(index: 1, needsTagsUpdate: true)
        let tags = ModelFactory.generateTags(inAmount: 5, for: artist.name)

        _ = try await artistService.updateArtist(artist, with: tags)

        let saveParameters = artistStore.saveParameters
        let updatedArtist = saveParameters?.first
        XCTAssertEqual(updatedArtist?.tags, tags)
        XCTAssertEqual(updatedArtist?.needsTagsUpdate, false)
    }

    func test_calculateTopTagsForAllArtists_callsCalculatorForEachArtist_andSavesArtists() async throws {
        let artistService = ArtistService(
            artistStore: artistStore,
            repository: StubArtistEmptyRepository(),
            mainScheduler: scheduler,
            backgroundScheduler: scheduler
        )

        let artists = ModelFactory.generateArtists(inAmount: 5)
        artistStore.customArtists = artists

        let calculator = MockArtistTopTagsCalculator()
        _ = try await artistService.calculateTopTagsForAllArtists(using: calculator)

        XCTAssertEqual(calculator.numberOfCalculateTopTagsCalled, artists.count)
        XCTAssertEqual(artistStore.saveParameters, artists)
    }

    func test_calculateTopTagsForArtist_callsCalculatorOnce_andSavesArtist() async throws {
        let artistService = ArtistService(artistStore: artistStore, repository: StubArtistEmptyRepository())

        let artist = ModelFactory.generateArtist(index: 1)
        let calculator = MockArtistTopTagsCalculator()

        _ = try await artistService.calculateTopTags(for: artist, using: calculator)

        XCTAssertEqual(calculator.numberOfCalculateTopTagsCalled, 1)
        XCTAssertEqual(artistStore.saveParameters?.first, artist)
    }

    func test_artists_createsCorrectMappedCollection() {
        let artistService = ArtistService(artistStore: artistStore, repository: StubArtistEmptyRepository())

        let predicate = NSPredicate(format: "name contains[cd] '1'")
        let sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        let mappedCollection = MockPersistentMappedCollection<Artist>(values: [])
        artistStore.customMappedCollection = AnyPersistentMappedCollection(mappedCollection)

        _ = artistService.artists(filteredUsing: predicate, sortedBy: sortDescriptors)
        let parameters = artistStore.mappedCollectionParameters

        XCTAssertEqual(parameters?.predicate, predicate)
        XCTAssertEqual(parameters?.sortDescriptors, sortDescriptors)
    }

    func test_getSimilarArtists_finishesWithSuccess() async throws {
        let similarArtistCount = 3

        let repository = MockArtistSimilarsRepository(shouldFailWithError: false, similarArtistProvider: {
            return ModelFactory.generateSimilarArtists(inAmount: similarArtistCount)
        })
        let artistService = ArtistService(artistStore: artistStore, repository: repository)

        let artist = ModelFactory.generateArtist()
        _ = try await artistService.getSimilarArtists(for: artist)

        XCTAssertEqual(repository.getSimilarArtistsParameters?.artist, artist)
        XCTAssertEqual(repository.getSimilarArtistsParameters?.limit, 20)

        let predicateFormat = "name IN {\"Artist1\", \"Artist2\", \"Artist3\"}"
        XCTAssertEqual(artistStore.fetchAllParameters?.predicateFormat, predicateFormat)
    }

    func test_getSimilarArtists_failsWithError() async throws {
        let repository = MockArtistSimilarsRepository(shouldFailWithError: true, similarArtistProvider: { [] })
        let artistService = ArtistService(artistStore: artistStore, repository: repository)

        let artist = ModelFactory.generateArtist()

        do {
            _ = try await artistService.getSimilarArtists(for: artist)
            XCTFail("Expected to throw an error")
        } catch {
            XCTAssertNil(artistStore.fetchAllParameters)
        }
    }
}
