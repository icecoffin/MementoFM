//
//  TagServiceTests.swift
//  MementoFM
//
//  Created by Daniel on 29/10/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest

@testable import MementoFM

final class TagServiceTests: XCTestCase {
    private var artistStore: MockArtistStore!

    override func setUp() {
        super.setUp()

        artistStore = MockArtistStore()
    }

    override func tearDown() {
        artistStore = nil

        super.tearDown()
    }

    func test_getTopTags_finishesWithSuccess() {
        let artistCount = 5
        let tagsPerArtist = 5

        let tagRepository = MockTagRepository()
        tagRepository.tagProvider = { artist in
            ModelFactory.generateTags(inAmount: tagsPerArtist, for: artist)
        }
        let tagService = TagService(artistStore: artistStore, repository: tagRepository)
        let artists = ModelFactory.generateArtists(inAmount: artistCount)

        var topTagsPages: [TopTagsPage] = []
        _ = tagService.getTopTags(for: artists)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure:
                    XCTFail("Unexpected failure")
                }
            } receiveValue: { topTagsPage in
                topTagsPages.append(topTagsPage)
            }

        let expectedTags = topTagsPages
            .map { ModelFactory.generateTags(inAmount: tagsPerArtist, for: $0.artist.name) }
        let receivedTags = topTagsPages.map { $0.topTagsList.tags }
        XCTAssertEqual(receivedTags, expectedTags)
    }

    func test_getTopTags_failsWithError() {
        let tagRepository = MockTagRepository()
        tagRepository.shouldFailWithError = true
        let tagService = TagService(artistStore: artistStore, repository: tagRepository)

        var didReceiveError = false
        let artists = ModelFactory.generateArtists(inAmount: 1)
        _ = tagService.getTopTags(for: artists)
            .sink { completion in
                switch completion {
                case .finished:
                    XCTFail("Expected to receive an error")
                case .failure:
                    didReceiveError = true
                }
            } receiveValue: { _ in
                XCTFail("Expected to receive an error")
            }

        XCTAssertTrue(didReceiveError)
    }

    func test_getAllTopTags_returnsTopTagsFromAllArtists() {
        let tags1 = ModelFactory.generateTags(inAmount: 10, for: "Artist1")
        let topTags1 = Array(tags1.prefix(5))
        let tags2 = ModelFactory.generateTags(inAmount: 10, for: "Artist2")
        let topTags2 = Array(tags2.prefix(5))

        let artist1 = Artist(
            name: "Artist1",
            playcount: 1,
            urlString: "",
            needsTagsUpdate: false,
            tags: tags1,
            topTags: topTags1,
            country: nil
        )
        let artist2 = Artist(
            name: "Artist2",
            playcount: 1,
            urlString: "",
            needsTagsUpdate: false,
            tags: tags2,
            topTags: topTags2,
            country: nil
        )

        let tagService = TagService(artistStore: artistStore, repository: MockTagRepository())

        artistStore.customArtists = [artist1, artist2]

        let topTags = tagService.getAllTopTags()
        let expectedTopTags = topTags1 + topTags2
        XCTAssertEqual(topTags, expectedTopTags)
    }
}
