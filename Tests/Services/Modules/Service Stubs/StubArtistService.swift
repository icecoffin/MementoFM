//
//  StubArtistService.swift
//  MementoFM
//
//  Created by Daniel on 11/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import PromiseKit
import RealmSwift

class StubArtistService: ArtistServiceProtocol {
  var expectedUser: String = ""
  var expectedLimit: Int = 0
  func getLibrary(for user: String, limit: Int, progress: ((Progress) -> Void)?) -> Promise<[Artist]> {
    expectedUser = user
    expectedLimit = limit
    return Promise(value: [])
  }

  var expectedSavingArtists = [Artist]()
  func saveArtists(_ artists: [Artist]) -> Promise<Void> {
    expectedSavingArtists = artists
    return Promise(value: ())
  }

  var expectedArtistsNeedingTagsUpdate: [Artist] = []
  func artistsNeedingTagsUpdate() -> [Artist] {
    return expectedArtistsNeedingTagsUpdate
  }

  var intersectingTopTagsExpectedArtist: Artist?
  func artistsWithIntersectingTopTags(for artist: Artist) -> [Artist] {
    intersectingTopTagsExpectedArtist = artist
    return []
  }

  var expectedUpdatingArtist: Artist?
  var expectedUpdatingTags: [Tag] = []
  var updateArtistShouldReturnError: Bool = false
  func updateArtist(_ artist: Artist, with tags: [Tag]) -> Promise<Artist> {
    expectedUpdatingArtist = artist
    expectedUpdatingTags = tags
    if updateArtistShouldReturnError {
      return Promise(error: NSError(domain: "MementoFM", code: 6, userInfo: nil))
    } else {
      return Promise(value: artist)
    }
  }

  var didCallCalculateTopTagsForAllArtists: Bool = false
  var calculateTopTagsForAllShouldReturnError: Bool = false
  func calculateTopTagsForAllArtists(using calculator: ArtistTopTagsCalculating) -> Promise<Void> {
    didCallCalculateTopTagsForAllArtists = true
    if calculateTopTagsForAllShouldReturnError {
      return Promise(error: NSError(domain: "MementoFM", code: 6, userInfo: nil))
    } else {
      return Promise(value: ())
    }
  }

  var expectedCalculateTopTagsArtist: Artist?
  var calculateTopTagsShouldReturnError: Bool = false
  func calculateTopTags(for artist: Artist, using calculator: ArtistTopTagsCalculating) -> Promise<Void> {
    expectedCalculateTopTagsArtist = artist
    if calculateTopTagsShouldReturnError {
      return Promise(error: NSError(domain: "MementoFM", code: 6, userInfo: nil))
    } else {
      return Promise(value: ())
    }
  }

  var expectedRealmForArtists: Realm!
  func artists(filteredUsing predicate: NSPredicate?,
               sortedBy sortDescriptors: [SortDescriptor]) -> RealmMappedCollection<Artist> {
    return RealmMappedCollection(realm: expectedRealmForArtists,
                                 predicate: predicate,
                                 sortDescriptors: sortDescriptors)
  }

  var expectedSimilarArtistsArtist: Artist?
  var expectedSimilarArtistsLimit: Int = 0
  var getSimilarArtistsShouldReturnError: Bool = false
  func getSimilarArtists(for artist: Artist, limit: Int) -> Promise<[Artist]> {
    expectedSimilarArtistsArtist = artist
    expectedSimilarArtistsLimit = limit
    if getSimilarArtistsShouldReturnError {
      return Promise(error: NSError(domain: "MementoFM", code: 6, userInfo: nil))
    } else {
      return Promise(value: [])
    }
  }
}
