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
    private var persistentStore: MockPersistentStore!
    private var scheduler: AnySchedulerOf<DispatchQueue>!

    override func setUp() {
        super.setUp()

        persistentStore = MockPersistentStore()
        scheduler = .immediate
    }

    override func tearDown() {
        persistentStore = nil
        scheduler = nil

        super.tearDown()
    }

    func test_getLibrary_emitsLibraryPages() {
        let totalPages = 5
        let artistsPerPage = 10

        let repository = MockArtistLibraryRepository(totalPages: totalPages, shouldFailWithError: false, artistProvider: { _ in
            return ModelFactory.generateArtists(inAmount: artistsPerPage)
        })
        let artistService = ArtistService(persistentStore: persistentStore, repository: repository)

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
        let artistService = ArtistService(persistentStore: persistentStore, repository: repository)

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

    func test_saveArtists_callsPersistentStore() {
        let artistService = ArtistService(persistentStore: persistentStore, repository: StubArtistEmptyRepository())

        let artists = ModelFactory.generateArtists(inAmount: 5)
        _ = artistService.saveArtists(artists)

        let saveParameters = persistentStore.saveParameters
        XCTAssertEqual(saveParameters?.objects as? [Artist], artists)
        XCTAssertEqual(saveParameters?.update, true)
    }

    func test_artistsNeedingTagsUpdate_callsPersistentStoreWithCorrectParameters() {
        let artistService = ArtistService(persistentStore: persistentStore, repository: StubArtistEmptyRepository())

        _ = artistService.artistsNeedingTagsUpdate()

        let predicate = persistentStore.objectsPredicate
        XCTAssertEqual(predicate?.predicateFormat, "needsTagsUpdate == 1")
    }

    func test_artistsWithIntersectingTopTags_callsPersistentStoreWithCorrectParameters() {
        let artistService = ArtistService(persistentStore: persistentStore, repository: StubArtistEmptyRepository())

        let tags = [Tag(name: "Tag1", count: 1),
                    Tag(name: "Tag2", count: 2),
                    Tag(name: "Tag3", count: 3)]
        let artist = ModelFactory.generateArtist(index: 1).updatingTopTags(to: tags)

        _ = artistService.artistsWithIntersectingTopTags(for: artist)

        let predicate = persistentStore.objectsPredicate
        XCTAssertEqual(predicate?.predicateFormat, "ANY topTags.name IN {\"Tag1\", \"Tag2\", \"Tag3\"} AND name != \"\(artist.name)\"")
    }

    func test_updateArtistWithTags_updatesArtist_andCallsPersistentStoreWithCorrectParameters() {
        let artistService = ArtistService(persistentStore: persistentStore, repository: StubArtistEmptyRepository())

        let artist = ModelFactory.generateArtist(index: 1, needsTagsUpdate: true)
        let tags = ModelFactory.generateTags(inAmount: 5, for: artist.name)

        _ = artistService.updateArtist(artist, with: tags)

        let saveParameters = persistentStore.saveParameters
        XCTAssertEqual(saveParameters?.update, true)

        let updatedArtist = saveParameters?.objects.first as? Artist
        XCTAssertEqual(updatedArtist?.tags, tags)
        XCTAssertEqual(updatedArtist?.needsTagsUpdate, false)
    }

    func test_calculateTopTagsForAllArtists_callsCalculatorForEachArtist_andSavesArtists() {
        let artistService = ArtistService(
            persistentStore: persistentStore,
            repository: StubArtistEmptyRepository(),
            mainScheduler: scheduler,
            backgroundScheduler: scheduler
        )

        let artists = ModelFactory.generateArtists(inAmount: 5)
        persistentStore.customObjects = artists

        let calculator = MockArtistTopTagsCalculator()
        _ = artistService.calculateTopTagsForAllArtists(using: calculator)
            .sink(receiveCompletion: { _ in }, receiveValue: { })

        XCTAssertEqual(calculator.numberOfCalculateTopTagsCalled, artists.count)
        XCTAssertEqual(persistentStore.saveParameters?.objects as? [Artist], artists)
        XCTAssertEqual(persistentStore.saveParameters?.update, true)
    }

    func test_calculateTopTagsForArtist_callsCalculatorOnce_andSavesArtist() {
        let artistService = ArtistService(persistentStore: persistentStore, repository: StubArtistEmptyRepository())

        let artist = ModelFactory.generateArtist(index: 1)
        let calculator = MockArtistTopTagsCalculator()

        _ = artistService.calculateTopTags(for: artist, using: calculator)

        XCTAssertEqual(calculator.numberOfCalculateTopTagsCalled, 1)
        XCTAssertEqual(persistentStore.saveParameters?.objects.first as? Artist, artist)
        XCTAssertEqual(persistentStore.saveParameters?.update, true)
    }

    func test_artists_createsCorrectMappedCollection() {
        let artistService = ArtistService(persistentStore: persistentStore, repository: StubArtistEmptyRepository())

        let predicate = NSPredicate(format: "name contains[cd] '1'")
        let sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        let mappedCollection = MockPersistentMappedCollection<Artist>(values: [])
        persistentStore.customMappedCollection = AnyPersistentMappedCollection(mappedCollection)

        _ = artistService.artists(filteredUsing: predicate, sortedBy: sortDescriptors)
        let parameters = persistentStore.mappedCollectionParameters

        XCTAssertEqual(parameters?.predicate, predicate)
        XCTAssertEqual(parameters?.sortDescriptors, sortDescriptors)
    }

    func test_getSimilarArtists_finishesWithSuccess() {
        let similarArtistCount = 3

        let repository = MockArtistSimilarsRepository(shouldFailWithError: false, similarArtistProvider: {
            return ModelFactory.generateSimilarArtists(inAmount: similarArtistCount)
        })
        let artistService = ArtistService(persistentStore: persistentStore, repository: repository)

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
        XCTAssertEqual(persistentStore.objectsPredicate?.predicateFormat, predicateFormat)
    }

    func test_getSimilarArtists_failsWithError() {
        let repository = MockArtistSimilarsRepository(shouldFailWithError: true, similarArtistProvider: { [] })
        let artistService = ArtistService(persistentStore: persistentStore, repository: repository)

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
        XCTAssertNil(persistentStore.objectsPredicate)
    }
}
