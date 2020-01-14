//
//  RecentTracksProcessorTests.swift
//  MementoFMTests
//
//  Created by Daniel on 01/12/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble
import PromiseKit

class RecentTracksProcessorTests: XCTestCase {
    var persistentStore: StubPersistentStore!

    override func setUp() {
        super.setUp()

        persistentStore = StubPersistentStore()
    }

    func test_processTracks_savesToPersistentStore() {
        let artist1 = ModelFactory.generateArtist(index: 1)
        let artist2 = ModelFactory.generateArtist(index: 2)
        let tracks = [Track(artist: artist1), Track(artist: artist1), Track(artist: artist2)]

        let recentTracksProcessor = RecentTracksProcessor()
        recentTracksProcessor.process(tracks: tracks, using: persistentStore).noError()

        expect(self.persistentStore.saveParameters?.objects.count) == 2
        expect(self.persistentStore.saveParameters?.update) == true
    }

    func test_processTracks_updatesPlaycount() {
        let artist1 = ModelFactory.generateArtist(index: 1)
        let artist2 = ModelFactory.generateArtist(index: 2)
        let tracks = [Track(artist: artist1), Track(artist: artist1), Track(artist: artist2)]

        let recentTracksProcessor = RecentTracksProcessor()
        recentTracksProcessor.process(tracks: tracks, using: persistentStore).noError()

        let artists = (persistentStore.saveParameters?.objects as? [Artist])?.sorted { $0.name < $1.name }
        let savedArtist1 = artists?[0]
        let savedArtist2 = artists?[1]

        expect(savedArtist1?.playcount) == 2
        expect(savedArtist2?.playcount) == 1
    }

    func test_processTracks_requestsArtistsForKeysFromPersistentStore() {
        let artist1 = ModelFactory.generateArtist(index: 1)
        let artist2 = ModelFactory.generateArtist(index: 2)
        let tracks = [Track(artist: artist1), Track(artist: artist1), Track(artist: artist2)]

        let recentTracksProcessor = RecentTracksProcessor()
        recentTracksProcessor.process(tracks: tracks, using: persistentStore).noError()

        expect(self.persistentStore.objectPrimaryKeys.sorted()) == ["Artist1", "Artist2"]
    }
}
