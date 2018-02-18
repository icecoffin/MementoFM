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
  var user: String = ""
  var limit: Int = 0
  var getLibraryShouldReturnError = false
  var progress = Progress()
  var didRequestLibrary = false
  func getLibrary(for user: String, limit: Int, progress: ((Progress) -> Void)?) -> Promise<[Artist]> {
    self.user = user
    self.limit = limit
    didRequestLibrary = true
    if getLibraryShouldReturnError {
      return Promise(error: NSError(domain: "MementoFM", code: 6, userInfo: nil))
    } else {
      progress?(self.progress)
      return .value([])
    }
  }

  var savingArtists = [Artist]()
  var didCallSaveArtists = false
  func saveArtists(_ artists: [Artist]) -> Promise<Void> {
    savingArtists = artists
    didCallSaveArtists = true
    return .value(())
  }

  var stubArtistsNeedingTagsUpdate: [Artist] = []
  var didRequestArtistsNeedingTagsUpdate = false
  func artistsNeedingTagsUpdate() -> [Artist] {
    didRequestArtistsNeedingTagsUpdate = true
    return stubArtistsNeedingTagsUpdate
  }

  var intersectingTopTagsArtist: Artist?
  var stubArtistsWithIntersectingTopTags: [Artist] = []
  func artistsWithIntersectingTopTags(for artist: Artist) -> [Artist] {
    intersectingTopTagsArtist = artist
    return stubArtistsWithIntersectingTopTags
  }

  var updatingArtist: Artist?
  var updatingTags: [Tag] = []
  var updateArtistShouldReturnError: Bool = false
  var didCallUpdateArtist: Bool = false
  func updateArtist(_ artist: Artist, with tags: [Tag]) -> Promise<Artist> {
    updatingArtist = artist
    updatingTags = tags
    didCallUpdateArtist = true
    if updateArtistShouldReturnError {
      return Promise(error: NSError(domain: "MementoFM", code: 6, userInfo: nil))
    } else {
      return .value(artist)
    }
  }

  var didCallCalculateTopTagsForAllArtists: Bool = false
  var calculateTopTagsForAllShouldReturnError: Bool = false
  func calculateTopTagsForAllArtists(using calculator: ArtistTopTagsCalculating) -> Promise<Void> {
    didCallCalculateTopTagsForAllArtists = true
    if calculateTopTagsForAllShouldReturnError {
      return Promise(error: NSError(domain: "MementoFM", code: 6, userInfo: nil))
    } else {
      return .value(())
    }
  }

  var stubCalculateTopTagsArtist: Artist?
  var calculateTopTagsShouldReturnError: Bool = false
  var didCallCalculateTopTags: Bool = false
  func calculateTopTags(for artist: Artist, using calculator: ArtistTopTagsCalculating) -> Promise<Void> {
    stubCalculateTopTagsArtist = artist
    didCallCalculateTopTags = true
    if calculateTopTagsShouldReturnError {
      return Promise(error: NSError(domain: "MementoFM", code: 6, userInfo: nil))
    } else {
      return .value(())
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
  var stubSimilarArtists: [Artist] = []
  func getSimilarArtists(for artist: Artist, limit: Int) -> Promise<[Artist]> {
    expectedSimilarArtistsArtist = artist
    expectedSimilarArtistsLimit = limit
    if getSimilarArtistsShouldReturnError {
      return Promise(error: NSError(domain: "MementoFM", code: 6, userInfo: nil))
    } else {
      return .value(stubSimilarArtists)
    }
  }
}
