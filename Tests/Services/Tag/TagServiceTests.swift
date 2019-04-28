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
  var realmService: RealmService!

  override func setUp() {
    super.setUp()
    realmService = RealmService(getRealm: {
      return RealmFactory.inMemoryRealm()
    })
  }

  override func tearDown() {
    realmService = nil
    super.tearDown()
  }

  func testGettingTopTagsForArtistsWithSuccess() {
    let artistCount = 5
    let tagsPerArtist = 5

    let tagRepository = TagStubRepository(shouldFailWithError: false, tagProvider: { artist in
      ModelFactory.generateTags(inAmount: tagsPerArtist, for: artist)
    })
    let tagService = TagService(persistentStore: realmService, repository: tagRepository)
    let artists = ModelFactory.generateArtists(inAmount: artistCount)

    var progressCallCount = 0
    waitUntil { done in
      tagService.getTopTags(for: artists, progress: { progress in
        let expectedTags = ModelFactory.generateTags(inAmount: tagsPerArtist, for: progress.artist.name)
        expect(progress.topTagsList.tags).to(equal(expectedTags))
        progressCallCount += 1
      }).done { _ in
        expect(progressCallCount).to(equal(artists.count))
        done()
      }.catch { _ in
        fail()
      }
    }
  }

  func testGettingTopTagsForArtistsWithError() {
    let artistCount = 5

    let tagRepository = TagStubRepository(shouldFailWithError: true, tagProvider: { _ in [] })
    let tagService = TagService(persistentStore: realmService, repository: tagRepository)
    let artists = ModelFactory.generateArtists(inAmount: artistCount)

    waitUntil { done in
      tagService.getTopTags(for: artists).done { _ in
        fail()
      }.catch { error in
        expect(error).toNot(beNil())
        done()
      }
    }
  }

  func testGettingAllTopTags() {
    let tags1 = ModelFactory.generateTags(inAmount: 10, for: "Artist1")
    let topTags1 = Array(tags1.prefix(5))
    let tags2 = ModelFactory.generateTags(inAmount: 10, for: "Artist2")
    let topTags2 = Array(tags2.prefix(5))

    let artist1 = Artist(name: "Artist1",
                         playcount: 1,
                         urlString: "",
                         imageURLString: nil,
                         needsTagsUpdate: false,
                         tags: tags1,
                         topTags: topTags1)
    let artist2 = Artist(name: "Artist2",
                         playcount: 1,
                         urlString: "",
                         imageURLString: nil,
                         needsTagsUpdate: false,
                         tags: tags2,
                         topTags: topTags2)

    let tagService = TagService(persistentStore: realmService, repository: TagEmptyStubRepository())

    waitUntil { done in
      self.realmService.save([artist1, artist2]).done { _ in
        let topTags = tagService.getAllTopTags()
        let expectedTopTags = topTags1 + topTags2
        expect(expectedTopTags).to(equal(topTags))
        done()
      }.noError()
    }
  }
}
