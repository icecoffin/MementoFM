//
//  ArtistsByTagViewModelTests.swift
//  MementoFMTests
//
//  Created by Daniel on 29/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble
import PromiseKit
import RealmSwift

class ArtistsByTagViewModelTests: XCTestCase {
  class Dependencies: ArtistsByTagViewModel.Dependencies {
    let artistService: ArtistServiceProtocol

    init(artistService: ArtistServiceProtocol) {
      self.artistService = artistService
    }
  }

  class StubArtistsByTagViewModelDelegate: ArtistListViewModelDelegate {
    var selectedArtist: Artist?
    func artistListViewModel(_ viewModel: ArtistListViewModel, didSelectArtist artist: Artist) {
      selectedArtist = artist
    }
  }

  var realm: Realm!
  var artistService: StubArtistService!
  var dependencies: Dependencies!

  var sampleArtists: [Artist] = {
    let tag1 = Tag(name: "Tag1", count: 1)
    let tag2 = Tag(name: "Tag2", count: 2)

    return [
      Artist(name: "Artist1", playcount: 1, urlString: "", imageURLString: nil, needsTagsUpdate: true, tags: [], topTags: [tag1]),
      Artist(name: "Artist2", playcount: 1, urlString: "", imageURLString: nil, needsTagsUpdate: true, tags: [], topTags: [tag1]),
      Artist(name: "Artist3", playcount: 1, urlString: "", imageURLString: nil, needsTagsUpdate: true, tags: [], topTags: [tag1]),
      Artist(name: "Artist4", playcount: 1, urlString: "", imageURLString: nil, needsTagsUpdate: true, tags: [], topTags: [tag2]),
      Artist(name: "Artist5", playcount: 1, urlString: "", imageURLString: nil, needsTagsUpdate: true, tags: [], topTags: [tag2]),
      Artist(name: "Artist6", playcount: 1, urlString: "", imageURLString: nil, needsTagsUpdate: true, tags: [], topTags: [tag2]),
      Artist(name: "Artist7", playcount: 1, urlString: "", imageURLString: nil, needsTagsUpdate: true, tags: [],
             topTags: [tag1, tag2])
    ]
  }()

  override func setUp() {
    realm = RealmFactory.inMemoryRealm()
    artistService = StubArtistService()
    artistService.expectedRealmForArtists = realm
    dependencies = Dependencies(artistService: artistService)
  }

  override func tearDown() {
    realm = nil
    artistService = nil
    dependencies = nil
  }

  func testGettingItemCount() {
    writeArtists()
    let viewModel = ArtistsByTagViewModel(tagName: "Tag1", dependencies: dependencies)
    expect(viewModel.itemCount).to(equal(4))
  }

  func testGettingTitle() {
    let viewModel = ArtistsByTagViewModel(tagName: "Tag1", dependencies: dependencies)
    expect(viewModel.title).to(equal("Tag1"))
  }

  func testGettingArtistViewModel() {
    writeArtists()
    let viewModel = ArtistsByTagViewModel(tagName: "Tag1", dependencies: dependencies)
    let indexPath = IndexPath(row: 1, section: 0)
    let artistViewModel = viewModel.artistViewModel(at: indexPath)
    expect(artistViewModel.name).to(equal("Artist2"))
  }

  func testSelectingArtist() {
    let artists = sampleArtists
    writeArtists()
    let viewModel = ArtistsByTagViewModel(tagName: "Tag1", dependencies: dependencies)
    let delegate = StubArtistsByTagViewModelDelegate()
    viewModel.delegate = delegate
    let indexPath = IndexPath(row: 1, section: 0)
    viewModel.selectArtist(at: indexPath)
    expect(delegate.selectedArtist).to(equal(artists[1]))
  }

  func testPerformingSearchWithEmptyResult() {
    writeArtists()
    let viewModel = ArtistsByTagViewModel(tagName: "Tag1", dependencies: dependencies)
    var expectedIsEmpty = true
    viewModel.onDidUpdateData = { isEmpty in
      expectedIsEmpty = isEmpty
    }
    viewModel.performSearch(withText: "1")
    expect(viewModel.itemCount).toEventually(equal(1))
    expect(expectedIsEmpty).toEventually(beFalse())
  }

  func testPerformingSearchWithNotEmptyResult() {
    writeArtists()
    let viewModel = ArtistsByTagViewModel(tagName: "Tag1", dependencies: dependencies)
    var expectedIsEmpty = false
    viewModel.onDidUpdateData = { isEmpty in
      expectedIsEmpty = isEmpty
    }
    viewModel.performSearch(withText: "231")
    expect(viewModel.itemCount).toEventually(equal(0))
    expect(expectedIsEmpty).toEventually(beTrue())
  }

  private func writeArtists() {
    let realmArtists = sampleArtists.map { RealmArtist.from(transient: $0) }
    realm.beginWrite()
    realm.add(realmArtists)
    try? realm.commitWrite()
  }
}
