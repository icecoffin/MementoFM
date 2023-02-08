//
//  ArtistServiceTests.swift
//  MementoFM
//
//  Created by Daniel on 03/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble
import CombineSchedulers
import TransientModels
import PersistenceInterface

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
                    fail()
                }
            }, receiveValue: { libraryPage in
                libraryPages.append(libraryPage)
            })

        expect(libraryPages.count) == totalPages

        let expectedArtists = (0..<totalPages).flatMap { _ in ModelFactory.generateArtists(inAmount: artistsPerPage) }
        let receivedArtists = libraryPages.map { $0.artists }.flatMap { $0 }
        expect(receivedArtists) == expectedArtists
    }

    func test_getLibrary_emitsErrorOnFailure() {
        let totalPages = 5
        let artistsPerPage = 10

        let repository = MockArtistLibraryRepository(totalPages: totalPages,
                                                     shouldFailWithError: true,
                                                     artistProvider: { _ in return [] })
        let artistService = ArtistService(persistentStore: persistentStore, repository: repository)

        var didCatchError = false
        _ = artistService.getLibrary(for: "user", limit: artistsPerPage)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    fail()
                case .failure:
                    didCatchError = true
                }
            }, receiveValue: { _ in fail() })

        expect(didCatchError) == true
    }

    func test_saveArtists_callsPersistentStore() {
        let artistService = ArtistService(persistentStore: persistentStore, repository: StubArtistEmptyRepository())

        let artists = ModelFactory.generateArtists(inAmount: 5)
        _ = artistService.saveArtists(artists)

        let saveParameters = persistentStore.saveParameters
        expect(saveParameters?.objects as? [Artist]) == artists
        expect(saveParameters?.update) == true
    }

    func test_artistsNeedingTagsUpdate_callsPersistentStoreWithCorrectParameters() {
        let artistService = ArtistService(persistentStore: persistentStore, repository: StubArtistEmptyRepository())

        _ = artistService.artistsNeedingTagsUpdate()

        let predicate = persistentStore.objectsPredicate
        expect(predicate?.predicateFormat) == "needsTagsUpdate == 1"
    }

    func test_artistsWithIntersectingTopTags_callsPersistentStoreWithCorrectParameters() {
        let artistService = ArtistService(persistentStore: persistentStore, repository: StubArtistEmptyRepository())

        let tags = [Tag(name: "Tag1", count: 1),
                    Tag(name: "Tag2", count: 2),
                    Tag(name: "Tag3", count: 3)]
        let artist = ModelFactory.generateArtist(index: 1).updatingTopTags(to: tags)

        _ = artistService.artistsWithIntersectingTopTags(for: artist)

        let predicate = persistentStore.objectsPredicate
        expect(predicate?.predicateFormat) == "ANY topTags.name IN {\"Tag1\", \"Tag2\", \"Tag3\"} AND name != \"\(artist.name)\""
    }

    func test_updateArtistWithTags_updatesArtist_andCallsPersistentStoreWithCorrectParameters() {
        let artistService = ArtistService(persistentStore: persistentStore, repository: StubArtistEmptyRepository())

        let artist = ModelFactory.generateArtist(index: 1, needsTagsUpdate: true)
        let tags = ModelFactory.generateTags(inAmount: 5, for: artist.name)

        _ = artistService.updateArtist(artist, with: tags)

        let saveParameters = persistentStore.saveParameters
        expect(saveParameters?.update) == true

        let updatedArtist = saveParameters?.objects.first as? Artist
        expect(updatedArtist?.tags) == tags
        expect(updatedArtist?.needsTagsUpdate) == false
    }

    func test_calculateTopTagsForAllArtists_callsCalculatorForEachArtist_andSavesArtists() {
        let artistService = ArtistService(persistentStore: persistentStore,
                                          repository: StubArtistEmptyRepository(),
                                          mainScheduler: scheduler,
                                          backgroundScheduler: scheduler)

        let artists = ModelFactory.generateArtists(inAmount: 5)
        persistentStore.customObjects = artists

        let calculator = MockArtistTopTagsCalculator()
        _ = artistService.calculateTopTagsForAllArtists(using: calculator)
            .sink(receiveCompletion: { _ in }, receiveValue: { })

        expect(calculator.numberOfCalculateTopTagsCalled) == artists.count
        expect(self.persistentStore.saveParameters?.objects as? [Artist]) == artists
        expect(self.persistentStore.saveParameters?.update) == true
    }

    func test_calculateTopTagsForArtist_callsCalculatorOnce_andSavesArtist() {
        let artistService = ArtistService(persistentStore: persistentStore, repository: StubArtistEmptyRepository())

        let artist = ModelFactory.generateArtist(index: 1)
        let calculator = MockArtistTopTagsCalculator()

        _ = artistService.calculateTopTags(for: artist, using: calculator)

        expect(calculator.numberOfCalculateTopTagsCalled) == 1
        expect(self.persistentStore.saveParameters?.objects.first as? Artist) == artist
        expect(self.persistentStore.saveParameters?.update) == true
    }

    func test_artists_createsCorrectMappedCollection() {
        let artistService = ArtistService(persistentStore: persistentStore, repository: StubArtistEmptyRepository())

        let predicate = NSPredicate(format: "name contains[cd] '1'")
        let sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        let mappedCollection = MockPersistentMappedCollection<Artist>(values: [])
        persistentStore.customMappedCollection = AnyPersistentMappedCollection(mappedCollection)

        _ = artistService.artists(filteredUsing: predicate, sortedBy: sortDescriptors)
        let parameters = persistentStore.mappedCollectionParameters

        expect(parameters?.predicate) == predicate
        expect(parameters?.sortDescriptors) == sortDescriptors
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
                    fail()
                }
            }, receiveValue: { _ in })

        expect(repository.getSimilarArtistsParameters?.artist) == artist
        expect(repository.getSimilarArtistsParameters?.limit) == 20

        let predicateFormat = "name IN {\"Artist1\", \"Artist2\", \"Artist3\"}"
        expect(self.persistentStore.objectsPredicate?.predicateFormat) == predicateFormat
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

        expect(didReceiveError) == true
        expect(self.persistentStore.objectsPredicate).to(beNil())
    }
}
