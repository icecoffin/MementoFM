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
    private func sampleArtist() -> Artist? {
        guard let json = Utils.json(forResource: "sample_artist", withExtension: "json") as? NSDictionary else {
            return nil
        }

        let mapper = Mapper(JSON: json)
        return try? Artist(map: mapper)
    }

    func testInitializingWithMapper() {
        let artist = sampleArtist()
        expect(artist?.name).to(equal("Tiger Army"))
        expect(artist?.playcount).to(equal(730))
        expect(artist?.urlString).to(equal("https://www.last.fm/music/Tiger+Army"))
        expect(artist?.needsTagsUpdate).to(beTrue())
        expect(artist?.tags).to(beEmpty())
        expect(artist?.topTags).to(beEmpty())
    }

    func testGettingIntersectingTopTagNames() {
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

        expect(intersectingTopTagNames).to(equal(["tag1", "tag3"]))
    }

    func testUpdatingPlaycount() {
        let artist = sampleArtist()

        let updatedArtist = artist?.updatingPlaycount(to: 100)

        expect(updatedArtist?.name).to(equal(artist?.name))
        expect(updatedArtist?.playcount).to(equal(100))
        expect(updatedArtist?.urlString).to(equal(artist?.urlString))
        expect(updatedArtist?.needsTagsUpdate).to(equal(artist?.needsTagsUpdate))
        expect(updatedArtist?.tags).to(equal(artist?.tags))
        expect(updatedArtist?.topTags).to(equal(artist?.topTags))
    }

    func testUpdatingTags() {
        let artist = sampleArtist()
        let tags = ModelFactory.generateTags(inAmount: 5, for: "Artist")

        let updatedArtist = artist?.updatingTags(to: tags, needsTagsUpdate: true)
        expect(updatedArtist?.name).to(equal(artist?.name))
        expect(updatedArtist?.playcount).to(equal(artist?.playcount))
        expect(updatedArtist?.urlString).to(equal(artist?.urlString))
        expect(updatedArtist?.needsTagsUpdate).to(equal(true))
        expect(updatedArtist?.tags).to(equal(tags))
        expect(updatedArtist?.topTags).to(equal(artist?.topTags))
    }

    func testUpdatingTopTags() {
        let artist = sampleArtist()
        let topTags = ModelFactory.generateTags(inAmount: 5, for: "Artist")

        let updatedArtist = artist?.updatingTopTags(to: topTags)
        expect(updatedArtist?.name).to(equal(artist?.name))
        expect(updatedArtist?.playcount).to(equal(artist?.playcount))
        expect(updatedArtist?.urlString).to(equal(artist?.urlString))
        expect(updatedArtist?.needsTagsUpdate).to(equal(true))
        expect(updatedArtist?.tags).to(equal(artist?.tags))
        expect(updatedArtist?.topTags).to(equal(topTags))
    }
}
