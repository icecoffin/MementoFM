//
//  RecentTracksProcessorTests.swift
//  MementoFMTests
//
//  Created by Daniel on 01/12/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM

final class RecentTracksProcessorTests: XCTestCase {
    private var artistStore: MockArtistStore!

    override func setUp() {
        super.setUp()

        artistStore = MockArtistStore()
    }

    override func tearDown() {
        artistStore = nil

        super.tearDown()
    }

    func test_processTracks_savesToPersistentStore() {
        let artist1 = ModelFactory.generateArtist(index: 1)
        let artist2 = ModelFactory.generateArtist(index: 2)
        let tracks = [Track(artist: artist1), Track(artist: artist1), Track(artist: artist2)]

        let recentTracksProcessor = RecentTracksProcessor(artistStore: artistStore)
        _ = recentTracksProcessor.process(tracks: tracks)

        XCTAssertEqual(artistStore.saveCallCount, 1)
        XCTAssertEqual(artistStore.saveParameters?.count, 2)
    }

    func test_processTracks_updatesPlaycount() {
        let artist1 = ModelFactory.generateArtist(index: 1)
        let artist2 = ModelFactory.generateArtist(index: 2)
        let tracks = [Track(artist: artist1), Track(artist: artist1), Track(artist: artist2)]

        let recentTracksProcessor = RecentTracksProcessor(artistStore: artistStore)
        _ = recentTracksProcessor.process(tracks: tracks)

        let artists = artistStore.saveParameters?.sorted { $0.name < $1.name }
        let savedArtist1 = artists?[0]
        let savedArtist2 = artists?[1]

        XCTAssertEqual(savedArtist1?.playcount, 2)
        XCTAssertEqual(savedArtist2?.playcount, 1)
    }

    func test_processTracks_requestsArtistsForKeysFromPersistentStore() {
        let artist1 = ModelFactory.generateArtist(index: 1)
        let artist2 = ModelFactory.generateArtist(index: 2)
        let tracks = [Track(artist: artist1), Track(artist: artist1), Track(artist: artist2)]

        let recentTracksProcessor = RecentTracksProcessor(artistStore: artistStore)
        _ = recentTracksProcessor.process(tracks: tracks)

        XCTAssertEqual(artistStore.artistForIDParameters.sorted(), ["test_id_1", "test_id_2"])
    }
}
