//
//  ArtistTests.swift
//  MementoFMTests
//
//  Created by Daniel on 22/10/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest

@testable import MementoFM

final class ArtistTests: XCTestCase {
    func test_decodeFromJSON_setsCorrectProperties() {
        let artist = makeSampleArtist()

        XCTAssertEqual(artist?.name, "Tiger Army")
        XCTAssertEqual(artist?.playcount, 730)
        XCTAssertEqual(artist?.urlString, "https://www.last.fm/music/Tiger+Army")
        XCTAssertEqual(artist?.needsTagsUpdate, true)
        XCTAssertEqual(artist?.tags.isEmpty, true)
        XCTAssertEqual(artist?.topTags.isEmpty, true)
    }

    func test_intersectingTopTagNames_returnsCorrectValue() {
        let topTags1 = [Tag(name: "tag1", count: 1),
                        Tag(name: "tag2", count: 2),
                        Tag(name: "tag3", count: 3)]
        let topTags2 = [Tag(name: "tag1", count: 1),
                        Tag(name: "tag3", count: 2),
                        Tag(name: "tag4", count: 3)]
        let artist1 = Artist(
            id: "test_id_1",
            name: "artist1",
            playcount: 1,
            urlString: "",
            needsTagsUpdate: false,
            tags: [],
            topTags: topTags1,
            country: nil
        )
        let artist2 = Artist(
            id: "test_id_2",
            name: "artist2",
            playcount: 1,
            urlString: "",
            needsTagsUpdate: false,
            tags: [],
            topTags: topTags2,
            country: nil
        )

        let intersectingTopTagNames = artist1.intersectingTopTagNames(with: artist2)

        XCTAssertEqual(intersectingTopTagNames, ["tag1", "tag3"])
    }

    func test_updatingPlaycount_setsCorrectProperties() {
        let artist = makeSampleArtist()

        let updatedArtist = artist?.updatingPlaycount(to: 100)

        XCTAssertEqual(updatedArtist?.name, artist?.name)
        XCTAssertEqual(updatedArtist?.playcount, 100)
        XCTAssertEqual(updatedArtist?.urlString, artist?.urlString)
        XCTAssertEqual(updatedArtist?.needsTagsUpdate, artist?.needsTagsUpdate)
        XCTAssertEqual(updatedArtist?.tags, artist?.tags)
        XCTAssertEqual(updatedArtist?.topTags, artist?.topTags)
    }

    func test_updatingTags_setsCorrectProperties() {
        let artist = makeSampleArtist()
        let tags = ModelFactory.generateTags(inAmount: 5, for: "Artist")

        let updatedArtist = artist?.updatingTags(to: tags, needsTagsUpdate: true)

        XCTAssertEqual(updatedArtist?.name, artist?.name)
        XCTAssertEqual(updatedArtist?.playcount, artist?.playcount)
        XCTAssertEqual(updatedArtist?.urlString, artist?.urlString)
        XCTAssertEqual(updatedArtist?.needsTagsUpdate, true)
        XCTAssertEqual(updatedArtist?.tags, tags)
        XCTAssertEqual(updatedArtist?.topTags, artist?.topTags)
    }

    func test_updatingTopTags_setsCorrectProperties() {
        let artist = makeSampleArtist()
        let topTags = ModelFactory.generateTags(inAmount: 5, for: "Artist")

        let updatedArtist = artist?.updatingTopTags(to: topTags)

        XCTAssertEqual(updatedArtist?.name, artist?.name)
        XCTAssertEqual(updatedArtist?.playcount, artist?.playcount)
        XCTAssertEqual(updatedArtist?.urlString, artist?.urlString)
        XCTAssertEqual(updatedArtist?.needsTagsUpdate, true)
        XCTAssertEqual(updatedArtist?.tags, artist?.tags)
        XCTAssertEqual(updatedArtist?.topTags, topTags)
    }

    // MARK: - Helpers

    private func makeSampleArtist() -> Artist? {
        guard let data = Utils.data(fromResource: "sample_artist", withExtension: "json") else {
            return nil
        }

        let jsonDecoder = JSONDecoder()
        return try? jsonDecoder.decode(Artist.self, from: data)
    }
}
