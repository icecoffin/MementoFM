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

class RealmArtistTests: XCTestCase {
  func testPrimaryKeyIsSet() {
    expect(RealmArtist.primaryKey()).to(equal("name"))
  }

  func testPropertiesAreSetCorrectlyAfterInit() {
    let realmArtist = RealmArtist()
    expect(realmArtist.name).to(beEmpty())
    expect(realmArtist.playcount).to(equal(0))
    expect(realmArtist.urlString).to(beEmpty())
    expect(realmArtist.needsTagsUpdate).to(beTrue())
    expect(realmArtist.tags).to(beEmpty())
    expect(realmArtist.topTags).to(beEmpty())
  }

  func testCreatingFromTransient() {
    let tags = ModelFactory.generateTags(inAmount: 5, for: "Test")
    let topTags = Array(tags.prefix(3))
    let transientArtist = Artist(name: "Test",
                                 playcount: 10,
                                 urlString: "https://example.com",
                                 needsTagsUpdate: false,
                                 tags: tags,
                                 topTags: topTags)
    let realmArtist = RealmArtist.from(transient: transientArtist)
    expect(realmArtist.name).to(equal(transientArtist.name))
    expect(realmArtist.playcount).to(equal(transientArtist.playcount))
    expect(realmArtist.urlString).to(equal(transientArtist.urlString))
    expect(realmArtist.needsTagsUpdate).to(equal(transientArtist.needsTagsUpdate))

    let expectedTags = Array(realmArtist.tags.map { $0.toTransient() })
    expect(expectedTags).to(equal(transientArtist.tags))
    let expectedTopTags = Array(realmArtist.topTags.map { $0.toTransient() })
    expect(expectedTopTags).to(equal(transientArtist.topTags))
  }

  func testConvertingToTransient() {
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
    expect(transientArtist.name).to(equal(realmArtist.name))
    expect(transientArtist.playcount).to(equal(realmArtist.playcount))
    expect(transientArtist.urlString).to(equal(realmArtist.urlString))
    expect(transientArtist.needsTagsUpdate).to(equal(realmArtist.needsTagsUpdate))
    expect(transientArtist.tags).to(equal(tags))
    expect(transientArtist.topTags).to(equal(topTags))
  }
}
