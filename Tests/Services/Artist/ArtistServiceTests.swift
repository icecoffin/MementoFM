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

    func test_getLibrary_emitsLibraryPages() {
        let totalPages = 5
        let artistsPerPage = 10

        let repository = MockArtistLibraryRepository(totalPages: totalPages, shouldFailWithError: false, artistProvider: { _ in
            return ModelFactory.generateArtists(inAmount: artistsPerPage)
        })
        let artistService = ArtistService(artistStore: artistStore, repository: repository)

        var libraryPages: [LibraryPage] = []
        _ = artistService.getLibrary(for: "user", limit: artistsPerPage)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure:
                    XCTFail("Unexpected failure")
                }
            }, receiveValue: { libraryPage in
                libraryPages.append(libraryPage)
            })

        XCTAssertEqual(libraryPages.count, totalPages)

        let expectedArtists = (0..<totalPages).flatMap { _ in ModelFactory.generateArtists(inAmount: artistsPerPage) }
        let receivedArtists = libraryPages.map { $0.artists }.flatMap { $0 }
        XCTAssertEqual(receivedArtists, expectedArtists)
    }

    func test_getLibrary_emitsErrorOnFailure() {
        let totalPages = 5
        let artistsPerPage = 10

        let repository = MockArtistLibraryRepository(
            totalPages: totalPages,
            shouldFailWithError: true,
            artistProvider: { _ in return [] }
        )
        let artistService = ArtistService(artistStore: artistStore, repository: repository)

        var didCatchError = false
        _ = artistService.getLibrary(for: "user", limit: artistsPerPage)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("Expected to receive an error")
                case .failure:
                    didCatchError = true
                }
            }, receiveValue: { _ in
                XCTFail("Expected to receive an error")
            })

        XCTAssertTrue(didCatchError)
    }

    func test_saveArtists_callsArtistStore() {
        let artistService = ArtistService(artistStore: artistStore, repository: StubArtistEmptyRepository())

        let artists = ModelFactory.generateArtists(inAmount: 5)
        _ = artistService.saveArtists(artists)

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

    func test_updateArtistWithTags_updatesArtist_andCallsArtistStoreWithCorrectParameters() {
        let artistService = ArtistService(artistStore: artistStore, repository: StubArtistEmptyRepository())

        let artist = ModelFactory.generateArtist(index: 1, needsTagsUpdate: true)
        let tags = ModelFactory.generateTags(inAmount: 5, for: artist.name)

        _ = artistService.updateArtist(artist, with: tags)

        let saveParameters = artistStore.saveParameters
        let updatedArtist = saveParameters?.first
        XCTAssertEqual(updatedArtist?.tags, tags)
        XCTAssertEqual(updatedArtist?.needsTagsUpdate, false)
    }

    func test_calculateTopTagsForAllArtists_callsCalculatorForEachArtist_andSavesArtists() {
        let artistService = ArtistService(
            artistStore: artistStore,
            repository: StubArtistEmptyRepository(),
            mainScheduler: scheduler,
            backgroundScheduler: scheduler
        )

        let artists = ModelFactory.generateArtists(inAmount: 5)
        artistStore.customArtists = artists

        let calculator = MockArtistTopTagsCalculator()
        _ = artistService.calculateTopTagsForAllArtists(using: calculator)
            .sink(receiveCompletion: { _ in }, receiveValue: { })

        XCTAssertEqual(calculator.numberOfCalculateTopTagsCalled, artists.count)
        XCTAssertEqual(artistStore.saveParameters, artists)
    }

    func test_calculateTopTagsForArtist_callsCalculatorOnce_andSavesArtist() {
        let artistService = ArtistService(artistStore: artistStore, repository: StubArtistEmptyRepository())

        let artist = ModelFactory.generateArtist(index: 1)
        let calculator = MockArtistTopTagsCalculator()

        _ = artistService.calculateTopTags(for: artist, using: calculator)

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

    func test_getSimilarArtists_finishesWithSuccess() {
        let similarArtistCount = 3

        let repository = MockArtistSimilarsRepository(shouldFailWithError: false, similarArtistProvider: {
            return ModelFactory.generateSimilarArtists(inAmount: similarArtistCount)
        })
        let artistService = ArtistService(artistStore: artistStore, repository: repository)

        let artist = ModelFactory.generateArtist()
        _ = artistService.getSimilarArtists(for: artist)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure:
                    XCTFail("Expected failure")
                }
            }, receiveValue: { _ in })

        XCTAssertEqual(repository.getSimilarArtistsParameters?.artist, artist)
        XCTAssertEqual(repository.getSimilarArtistsParameters?.limit, 20)

        let predicateFormat = "name IN {\"Artist1\", \"Artist2\", \"Artist3\"}"
        XCTAssertEqual(artistStore.fetchAllParameters?.predicateFormat, predicateFormat)
    }

    func test_getSimilarArtists_failsWithError() {
        let repository = MockArtistSimilarsRepository(shouldFailWithError: true, similarArtistProvider: { [] })
        let artistService = ArtistService(artistStore: artistStore, repository: repository)

        let artist = ModelFactory.generateArtist()

        var didReceiveError = false
        _ = artistService.getSimilarArtists(for: artist)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure:
                    didReceiveError = true
                }
            }, receiveValue: { _ in })

        XCTAssertTrue(didReceiveError)
        XCTAssertNil(artistStore.fetchAllParameters)
    }
}
