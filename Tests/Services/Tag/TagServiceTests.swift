//
//  TagServiceTests.swift
//  MementoFM
//
//  Created by Daniel on 29/10/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
import Nimble
@testable import MementoFM
import PromiseKit

class TagServiceTests: XCTestCase {
    var persistentStore: StubPersistentStore!

    override func setUp() {
        super.setUp()

        persistentStore = StubPersistentStore()
    }

    func test_getTopTags_finishesWithSuccess() {
        let artistCount = 5
        let tagsPerArtist = 5

        let tagRepository = TagStubRepository(shouldFailWithError: false, tagProvider: { artist in
            ModelFactory.generateTags(inAmount: tagsPerArtist, for: artist)
        })
        let tagService = TagService(persistentStore: persistentStore, repository: tagRepository)
        let artists = ModelFactory.generateArtists(inAmount: artistCount)

        var progressCallCount = 0
        waitUntil { done in
            tagService.getTopTags(for: artists, progress: { progress in
                let expectedTags = ModelFactory.generateTags(inAmount: tagsPerArtist, for: progress.artist.name)
                expect(progress.topTagsList.tags) == expectedTags
                progressCallCount += 1
            }).done { _ in
                expect(progressCallCount) == artists.count
                done()
            }.catch { _ in
                fail()
            }
        }
    }

    func test_getTopTags_failsWithError() {
        let tagRepository = TagStubRepository(shouldFailWithError: true, tagProvider: { _ in [] })
        let tagService = TagService(persistentStore: persistentStore, repository: tagRepository)

        var didReceiveError = false
        let artists = ModelFactory.generateArtists(inAmount: 1)
        tagService.getTopTags(for: artists).done { _ in
            fail()
        }.catch { _ in
            didReceiveError = true
        }

        expect(didReceiveError).toEventually(beTrue())
    }

    func test_getAllTopTags_returnsTopTagsFromAllArtists() {
        let tags1 = ModelFactory.generateTags(inAmount: 10, for: "Artist1")
        let topTags1 = Array(tags1.prefix(5))
        let tags2 = ModelFactory.generateTags(inAmount: 10, for: "Artist2")
        let topTags2 = Array(tags2.prefix(5))

        let artist1 = Artist(name: "Artist1",
                             playcount: 1,
                             urlString: "",
                             needsTagsUpdate: false,
                             tags: tags1,
                             topTags: topTags1,
                             country: nil)
        let artist2 = Artist(name: "Artist2",
                             playcount: 1,
                             urlString: "",
                             needsTagsUpdate: false,
                             tags: tags2,
                             topTags: topTags2,
                             country: nil)

        let tagService = TagService(persistentStore: persistentStore, repository: TagEmptyStubRepository())

        persistentStore.customObjects = [artist1, artist2]

        let topTags = tagService.getAllTopTags()
        let expectedTopTags = topTags1 + topTags2
        expect(topTags) == expectedTopTags
    }
}
