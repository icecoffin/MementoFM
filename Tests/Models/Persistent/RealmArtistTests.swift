//
//  RealmArtistTests.swift
//  MementoFMTests
//
//  Created by Daniel on 06/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import RealmSwift
import Nimble

final class RealmArtistTests: XCTestCase {
    func test_primaryKey_isSet() {
        expect(RealmArtist.primaryKey()) == "name"
    }

    func test_init_setsCorrectProperties() {
        let realmArtist = RealmArtist()

        expect(realmArtist.name).to(beEmpty())
        expect(realmArtist.playcount) == 0
        expect(realmArtist.urlString).to(beEmpty())
        expect(realmArtist.needsTagsUpdate) == true
        expect(realmArtist.tags).to(beEmpty())
        expect(realmArtist.topTags).to(beEmpty())
    }

    func test_fromTransient_setsCorrectProperties() {
        let tags = ModelFactory.generateTags(inAmount: 5, for: "Test")
        let topTags = Array(tags.prefix(3))
        let transientArtist = Artist(
            name: "Test",
            playcount: 10,
            urlString: "https://example.com",
            needsTagsUpdate: false,
            tags: tags,
            topTags: topTags,
            country: nil
        )

        let realmArtist = RealmArtist.from(transient: transientArtist)

        expect(realmArtist.name) == transientArtist.name
        expect(realmArtist.playcount) == transientArtist.playcount
        expect(realmArtist.urlString) == transientArtist.urlString
        expect(realmArtist.needsTagsUpdate) == transientArtist.needsTagsUpdate

        let expectedTags = Array(realmArtist.tags.map { $0.toTransient() })
        expect(expectedTags) == transientArtist.tags

        let expectedTopTags = Array(realmArtist.topTags.map { $0.toTransient() })
        expect(expectedTopTags) == transientArtist.topTags
    }

    func test_toTransient_setsCorrectProperties() {
        let realmArtist = RealmArtist()
        realmArtist.name = "Test"
        realmArtist.playcount = 10
        realmArtist.urlString = "https://example.com"
        realmArtist.needsTagsUpdate = false

        let tags = ModelFactory.generateTags(inAmount: 5, for: "Test")
        let topTags = Array(tags.prefix(3))

        let realmTags = tags.map { RealmTag.from(transient: $0) }
        realmArtist.tags.append(objectsIn: realmTags)

        let realmTopTags = topTags.map { RealmTag.from(transient: $0) }
        realmArtist.topTags.append(objectsIn: realmTopTags)

        let transientArtist = realmArtist.toTransient()

        expect(transientArtist.name) == realmArtist.name
        expect(transientArtist.playcount) == realmArtist.playcount
        expect(transientArtist.urlString) == realmArtist.urlString
        expect(transientArtist.needsTagsUpdate) == realmArtist.needsTagsUpdate
        expect(transientArtist.tags) == tags
        expect(transientArtist.topTags) == topTags
    }
}
