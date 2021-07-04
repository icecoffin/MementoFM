//
//  ArtistTests.swift
//  MementoFMTests
//
//  Created by Daniel on 22/10/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
import Nimble
@testable import MementoFM
import Mapper

class ArtistTests: XCTestCase {
    func test_initWithMap_setsCorrectProperties() {
        let artist = makeSampleArtist()

        expect(artist?.name) == "Tiger Army"
        expect(artist?.playcount) == 730
        expect(artist?.urlString) == "https://www.last.fm/music/Tiger+Army"
        expect(artist?.needsTagsUpdate) == true
        expect(artist?.tags).to(beEmpty())
        expect(artist?.topTags).to(beEmpty())
    }

    func test_intersectingTopTagNames_returnsCorrectValue() {
        let topTags1 = [Tag(name: "tag1", count: 1),
                        Tag(name: "tag2", count: 2),
                        Tag(name: "tag3", count: 3)]
        let topTags2 = [Tag(name: "tag1", count: 1),
                        Tag(name: "tag3", count: 2),
                        Tag(name: "tag4", count: 3)]
        let artist1 = Artist(name: "artist1",
                             playcount: 1,
                             urlString: "",
                             needsTagsUpdate: false,
                             tags: [],
                             topTags: topTags1,
                             country: nil)
        let artist2 = Artist(name: "artist2",
                             playcount: 1,
                             urlString: "",
                             needsTagsUpdate: false,
                             tags: [],
                             topTags: topTags2,
                             country: nil)

        let intersectingTopTagNames = artist1.intersectingTopTagNames(with: artist2)

        expect(intersectingTopTagNames) == ["tag1", "tag3"]
    }

    func test_updatingPlaycount_setsCorrectProperties() {
        let artist = makeSampleArtist()

        let updatedArtist = artist?.updatingPlaycount(to: 100)

        expect(updatedArtist?.name) == artist?.name
        expect(updatedArtist?.playcount) == 100
        expect(updatedArtist?.urlString) == artist?.urlString
        expect(updatedArtist?.needsTagsUpdate) == artist?.needsTagsUpdate
        expect(updatedArtist?.tags) == artist?.tags
        expect(updatedArtist?.topTags) == artist?.topTags
    }

    func test_updatingTags_setsCorrectProperties() {
        let artist = makeSampleArtist()
        let tags = ModelFactory.generateTags(inAmount: 5, for: "Artist")

        let updatedArtist = artist?.updatingTags(to: tags, needsTagsUpdate: true)

        expect(updatedArtist?.name) == artist?.name
        expect(updatedArtist?.playcount) == artist?.playcount
        expect(updatedArtist?.urlString) == artist?.urlString
        expect(updatedArtist?.needsTagsUpdate) == true
        expect(updatedArtist?.tags) == tags
        expect(updatedArtist?.topTags) == artist?.topTags
    }

    func test_updatingTopTags_setsCorrectProperties() {
        let artist = makeSampleArtist()
        let topTags = ModelFactory.generateTags(inAmount: 5, for: "Artist")

        let updatedArtist = artist?.updatingTopTags(to: topTags)

        expect(updatedArtist?.name) == artist?.name
        expect(updatedArtist?.playcount) == artist?.playcount
        expect(updatedArtist?.urlString) == artist?.urlString
        expect(updatedArtist?.needsTagsUpdate) == true
        expect(updatedArtist?.tags) == artist?.tags
        expect(updatedArtist?.topTags) == topTags
    }

    private func makeSampleArtist() -> Artist? {
        guard let data = Utils.data(fromResource: "sample_artist", withExtension: "json") else {
            return nil
        }

        let jsonDecoder = JSONDecoder()
        return try? jsonDecoder.decode(Artist.self, from: data)
    }
}
