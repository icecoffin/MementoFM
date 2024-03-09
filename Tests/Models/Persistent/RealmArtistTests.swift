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

final class RealmArtistTests: XCTestCase {
    func test_primaryKey_isSet() {
        XCTAssertEqual(RealmArtist.primaryKey(), "name")
    }

    func test_init_setsCorrectProperties() {
        let realmArtist = RealmArtist()

        XCTAssertTrue(realmArtist.name.isEmpty)
        XCTAssertEqual(realmArtist.playcount, 0)
        XCTAssertTrue(realmArtist.urlString.isEmpty)
        XCTAssertTrue(realmArtist.needsTagsUpdate)
        XCTAssertTrue(realmArtist.tags.isEmpty)
        XCTAssertTrue(realmArtist.topTags.isEmpty)
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

        XCTAssertEqual(realmArtist.name, transientArtist.name)
        XCTAssertEqual(realmArtist.playcount, transientArtist.playcount)
        XCTAssertEqual(realmArtist.urlString, transientArtist.urlString)
        XCTAssertEqual(realmArtist.needsTagsUpdate, transientArtist.needsTagsUpdate)

        let expectedTags = Array(realmArtist.tags.map { $0.toTransient() })
        XCTAssertEqual(expectedTags, transientArtist.tags)

        let expectedTopTags = Array(realmArtist.topTags.map { $0.toTransient() })
        XCTAssertEqual(expectedTopTags, transientArtist.topTags)
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

        XCTAssertEqual(transientArtist.name, realmArtist.name)
        XCTAssertEqual(transientArtist.playcount, realmArtist.playcount)
        XCTAssertEqual(transientArtist.urlString, realmArtist.urlString)
        XCTAssertEqual(transientArtist.needsTagsUpdate, realmArtist.needsTagsUpdate)
        XCTAssertEqual(transientArtist.tags, tags)
        XCTAssertEqual(transientArtist.topTags, topTags)
    }
}
