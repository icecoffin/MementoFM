//
//  ArtistServiceTests.swift
//  MementoFM
//
//  Created by Daniel on 03/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble
import PromiseKit
import RealmSwift

class ArtistServiceTests: XCTestCase {
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

  func testGettingLibraryWithSuccess() {
    let totalPages = 5
    let artistsPerPage = 10

    let repository = ArtistLibraryStubRepository(totalPages: totalPages, shouldFailWithError: false, artistProvider: { _ in
      return ModelFactory.generateArtists(inAmount: artistsPerPage)
    })
    let artistService = ArtistService(realmService: realmService, repository: repository)

    var progressCallCount = 0
    waitUntil { done in
      artistService.getLibrary(for: "user", limit: artistsPerPage, progress: { _ in
        progressCallCount += 1
      }).done { artists in
        expect(progressCallCount).to(equal(totalPages - 1))
        let expectedArtists = (0..<totalPages).flatMap { _ in ModelFactory.generateArtists(inAmount: artistsPerPage) }
        expect(expectedArtists).to(equal(artists))
        done()
      }.catch { _ in
        fail()
      }
    }
  }

  func testGettingLibraryWithFailure() {
    let totalPages = 5
    let artistsPerPage = 10

    let repository = ArtistLibraryStubRepository(totalPages: totalPages, shouldFailWithError: true, artistProvider: { _ in return [] })
    let artistService = ArtistService(realmService: realmService, repository: repository)

    waitUntil { done in
      artistService.getLibrary(for: "user", limit: artistsPerPage, progress: nil).done { _ in
        fail()
      }.catch { error in
        expect(error).toNot(beNil())
        done()
      }
    }
  }

  func testSavingArtists() {
    let artistService = ArtistService(realmService: realmService, repository: ArtistEmptyStubRepository())

    let artists = ModelFactory.generateArtists(inAmount: 5)
    waitUntil { done in
      artistService.saveArtists(artists).done { _ in
        let expectedArtists = self.realmService.objects(Artist.self)
        expect(expectedArtists).to(equal(artists))
        done()
      }.noError()
    }
  }

  func testGettingArtistsNeedingTagsUpdate() {
    let artistService = ArtistService(realmService: realmService, repository: ArtistEmptyStubRepository())

    let artists1 = ModelFactory.generateArtists(inAmount: 5)
    let artists2 = ModelFactory.generateArtists(inAmount: 5, needsTagsUpdate: true)
    waitUntil { done in
      self.realmService.save(artists1 + artists2).done { _ in
        let expectedArtists = artistService.artistsNeedingTagsUpdate()
        expect(expectedArtists).to(equal(artists2))
        done()
      }.noError()
    }
  }

  func testGettingArtistsWithIntersectingTopTags() {
    let artistService = ArtistService(realmService: realmService, repository: ArtistEmptyStubRepository())

    let tags1 = [Tag(name: "Tag1", count: 1),
                 Tag(name: "Tag2", count: 2),
                 Tag(name: "Tag3", count: 3)]
    let tags2 = [Tag(name: "Tag1", count: 1),
                 Tag(name: "Tag4", count: 4)]
    let tags3 = [Tag(name: "Tag5", count: 5)]

    let artist1 = ModelFactory.generateArtist(index: 1).updatingTopTags(to: tags1)
    let artist2 = ModelFactory.generateArtist(index: 2).updatingTopTags(to: tags2)
    let artist3 = ModelFactory.generateArtist(index: 3).updatingTopTags(to: tags3)
    waitUntil { done in
      firstly {
        self.realmService.save([artist1, artist2, artist3])
      }.done { _ in
        let artists1 = artistService.artistsWithIntersectingTopTags(for: artist1)
        expect(artists1).to(equal([artist2]))
        let artists2 = artistService.artistsWithIntersectingTopTags(for: artist2)
        expect(artists2).to(equal([artist1]))
        let artists3 = artistService.artistsWithIntersectingTopTags(for: artist3)
        expect(artists3).to(beEmpty())
        done()
      }.noError()
    }
  }

  func testUpdatingArtistWithTags() {
    let artistService = ArtistService(realmService: realmService, repository: ArtistEmptyStubRepository())

    let artist = ModelFactory.generateArtist(index: 1, needsTagsUpdate: true)
    let tags = ModelFactory.generateTags(inAmount: 5, for: artist.name)
    waitUntil { done in
      artistService.updateArtist(artist, with: tags).done { _ in
        let expectedArtist = self.realmService.object(ofType: Artist.self, forPrimaryKey: artist.name)
        expect(expectedArtist?.tags).to(equal(tags))
        expect(expectedArtist?.needsTagsUpdate).to(beFalse())
        done()
      }.noError()
    }
  }

  func testCalculatingTopTagsForAllArtists() {
    let artistService = ArtistService(realmService: realmService, repository: ArtistEmptyStubRepository())

    let artists = ModelFactory.generateArtists(inAmount: 5)
    let calculator = ArtistStubTopTagsCalculator()

    waitUntil { done in
      firstly {
        return artistService.saveArtists(artists)
      }.then {
        artistService.calculateTopTagsForAllArtists(using: calculator)
      }.done { _ in
        expect(calculator.numberOfCalculateTopTagsCalled).to(equal(artists.count))
        done()
      }.noError()
    }
  }

  func testCalculatingTopTagsForArtist() {
    let artistService = ArtistService(realmService: realmService, repository: ArtistEmptyStubRepository())

    let artist = ModelFactory.generateArtist(index: 1)
    let calculator = ArtistStubTopTagsCalculator()

    waitUntil { done in
      artistService.calculateTopTags(for: artist, using: calculator).done { _ in
        let expectedArtist = self.realmService.object(ofType: Artist.self, forPrimaryKey: artist.name)
        expect(expectedArtist).toNot(beNil())
        expect(calculator.numberOfCalculateTopTagsCalled).to(equal(1))
        done()
      }.noError()
    }
  }

  func testCreatingArtistsMappedCollection() {
    let artistService = ArtistService(realmService: realmService, repository: ArtistEmptyStubRepository())

    let predicate = NSPredicate(format: "name contains[cd] '1'")
    let sortDescriptors = [SortDescriptor(keyPath: "name")]
    let artistsMappedCollection = artistService.artists(filteredUsing: predicate, sortedBy: sortDescriptors)
    expect(artistsMappedCollection.predicate).to(equal(predicate))
    expect(artistsMappedCollection.sortDescriptors).to(equal(sortDescriptors))
  }

  func testGettingSimilarArtistsWithSuccess() {
    let similarArtistCount = 10

    let repository = ArtistSimilarsStubRepository(shouldFailWithError: false, similarArtistProvider: {
      return ModelFactory.generateSimilarArtists(inAmount: similarArtistCount)
    })
    let artistService = ArtistService(realmService: realmService, repository: repository)

    let artist = ModelFactory.generateArtist()
    waitUntil { done in
      let artists = ModelFactory.generateArtists(inAmount: 10)
      firstly {
        self.realmService.save(artists)
      }.then {
        artistService.getSimilarArtists(for: artist)
      }.done { artists in
        let expectedArtists = ModelFactory.generateArtists(inAmount: similarArtistCount)
        expect(expectedArtists).to(equal(artists))
        done()
      }.catch { _ in
        fail()
      }
    }
  }

  func testGettingSimilarArtistsWithFailure() {
    let repository = ArtistSimilarsStubRepository(shouldFailWithError: true, similarArtistProvider: { [] })
    let artistService = ArtistService(realmService: realmService, repository: repository)

    let artist = ModelFactory.generateArtist()
    waitUntil { done in
      artistService.getSimilarArtists(for: artist).done { _ in
        fail()
      }.catch { _ in
        done()
      }
    }
  }
}
