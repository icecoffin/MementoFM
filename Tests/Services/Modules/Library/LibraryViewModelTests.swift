//
//  LibraryViewModelTests.swift
//  MementoFMTests
//
//  Created by Daniel on 03/12/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble
import RealmSwift

class LibraryViewModelTests: XCTestCase {
  class Dependencies: LibraryViewModel.Dependencies {
    let libraryUpdater: LibraryUpdaterProtocol
    let artistService: ArtistServiceProtocol
    let userService: UserServiceProtocol

    init(libraryUpdater: LibraryUpdaterProtocol, artistService: ArtistServiceProtocol, userService: UserServiceProtocol) {
      self.libraryUpdater = libraryUpdater
      self.artistService = artistService
      self.userService = userService
    }
  }

  class StubLibraryViewModelDelegate: ArtistListViewModelDelegate {
    var selectedArtist: Artist?
    func artistListViewModel(_ viewModel: ArtistListViewModel, didSelectArtist artist: Artist) {
      selectedArtist = artist
    }
  }

  class StubApplicationStateObserver: ApplicationStateObserving {
    var onApplicationDidBecomeActive: (() -> Void)?
  }

  var realm: Realm!
  var libraryUpdater: StubLibraryUpdater!
  var artistService: StubArtistService!
  var userService: StubUserService!
  var dependencies: Dependencies!

  var sampleArtists: [Artist] = {
    return [
      Artist(name: "Artist1", playcount: 1, urlString: "", imageURLString: nil, needsTagsUpdate: true, tags: [], topTags: []),
      Artist(name: "Artist2", playcount: 1, urlString: "", imageURLString: nil, needsTagsUpdate: true, tags: [], topTags: []),
      Artist(name: "Artist3", playcount: 1, urlString: "", imageURLString: nil, needsTagsUpdate: true, tags: [], topTags: []),
      Artist(name: "Artist4", playcount: 1, urlString: "", imageURLString: nil, needsTagsUpdate: true, tags: [], topTags: []),
      Artist(name: "Artist5", playcount: 1, urlString: "", imageURLString: nil, needsTagsUpdate: true, tags: [], topTags: []),
      Artist(name: "Artist6", playcount: 1, urlString: "", imageURLString: nil, needsTagsUpdate: true, tags: [], topTags: []),
      Artist(name: "Artist7", playcount: 1, urlString: "", imageURLString: nil, needsTagsUpdate: true, tags: [], topTags: [])
    ]
  }()

  override func setUp() {
    super.setUp()
    realm = RealmFactory.inMemoryRealm()
    libraryUpdater = StubLibraryUpdater()
    artistService = StubArtistService()
    artistService.expectedRealmForArtists = realm
    userService = StubUserService()
    dependencies = Dependencies(libraryUpdater: libraryUpdater, artistService: artistService, userService: userService)
  }

  override func tearDown() {
    realm = nil
    libraryUpdater = nil
    artistService = nil
    userService = nil
    dependencies = nil
    super.tearDown()
  }

  func testMakingFirstUpdate() {
    let viewModel = LibraryViewModel(dependencies: dependencies)

    libraryUpdater.isFirstUpdate = true
    viewModel.requestDataIfNeeded()
    expect(self.libraryUpdater.didRequestData).to(beTrue())
  }

  func testRequestingDataByTimeInterval() {
    let viewModel = LibraryViewModel(dependencies: dependencies)

    libraryUpdater.lastUpdateTimestamp = 100
    viewModel.requestDataIfNeeded(currentTimestamp: 200)
    expect(self.libraryUpdater.didRequestData).to(beTrue())
  }

  func testRequestingDataWhenNotNeeded() {
    let viewModel = LibraryViewModel(dependencies: dependencies)

    libraryUpdater.lastUpdateTimestamp = 100
    libraryUpdater.isFirstUpdate = false
    viewModel.requestDataIfNeeded(currentTimestamp: 100)
    expect(self.libraryUpdater.didRequestData).to(beFalse())
  }

  func testGettingItemCount() {
    writeArtists()
    let viewModel = LibraryViewModel(dependencies: dependencies)
    expect(viewModel.itemCount).to(equal(sampleArtists.count))
  }

  func testGettingArtistViewModel() {
    writeArtists()
    let viewModel = LibraryViewModel(dependencies: dependencies)
    let indexPath = IndexPath(row: 1, section: 0)
    let artistViewModel = viewModel.artistViewModel(at: indexPath)
    expect(artistViewModel.name).to(equal(sampleArtists[1].name))
  }

  func testSelectingArtist() {
    writeArtists()
    let viewModel = LibraryViewModel(dependencies: dependencies)
    let delegate = StubLibraryViewModelDelegate()
    viewModel.delegate = delegate
    let indexPath = IndexPath(row: 1, section: 0)
    viewModel.selectArtist(at: indexPath)
    expect(delegate.selectedArtist).to(equal(sampleArtists[1]))
  }

  func testPerformingSearch() {
    writeArtists()
    let viewModel = LibraryViewModel(dependencies: dependencies)

    viewModel.performSearch(withText: "1")
    expect(viewModel.itemCount).to(equal(1))

    viewModel.performSearch(withText: "")
    expect(viewModel.itemCount).to(equal(sampleArtists.count))
  }

  func testRequestingDataOnApplicationDidBecomeActive() {
    let applicationStateObserver = StubApplicationStateObserver()
    let viewModel = LibraryViewModel(dependencies: dependencies, applicationStateObserver: applicationStateObserver)
    // Suppress 'unused variable' warning
    _ = viewModel.delegate
    applicationStateObserver.onApplicationDidBecomeActive?()
    expect(self.libraryUpdater.didRequestData).to(beTrue())
  }

  func testStartLoading() {
    let viewModel = LibraryViewModel(dependencies: dependencies)
    var didStartLoading = false
    viewModel.onDidStartLoading = {
      didStartLoading = true
    }
    libraryUpdater.simulateStartLoading()
    expect(didStartLoading).to(beTrue())
  }

  func testFinishLoading() {
    let viewModel = LibraryViewModel(dependencies: dependencies)
    var didFinishLoading = false
    viewModel.onDidFinishLoading = {
      didFinishLoading = true
    }
    var didUpdateData = false
    var dataIsEmpty = false
    viewModel.onDidUpdateData = { isEmpty in
      didUpdateData = true
      dataIsEmpty = isEmpty
    }
    libraryUpdater.simulateFinishLoading()
    expect(didFinishLoading).to(beTrue())
    expect(didUpdateData).to(beTrue())
    expect(dataIsEmpty).to(beTrue())
  }

  func testGettingErrorWhileUpdating() {
    let viewModel = LibraryViewModel(dependencies: dependencies)
    var didReceiveError = false
    viewModel.onDidReceiveError = { _ in
      didReceiveError = true
    }
    libraryUpdater.simulateError(NSError(domain: "MementoFM", code: 6, userInfo: nil))
    expect(didReceiveError).to(beTrue())
  }

  func testUpdatingStatus() {
    let viewModel = LibraryViewModel(dependencies: dependencies)
    var statuses: [String] = []

    viewModel.onDidChangeStatus = { status in
      statuses.append(status)
    }

    libraryUpdater.simulateStatusChange(.artistsFirstPage)
    let artistsProgress = Progress()
    artistsProgress.totalUnitCount = 10
    artistsProgress.completedUnitCount = 1
    libraryUpdater.simulateStatusChange(.artists(progress: artistsProgress))
    libraryUpdater.simulateStatusChange(.recentTracksFirstPage)
    let recentTracksProgress = Progress()
    recentTracksProgress.totalUnitCount = 10
    recentTracksProgress.completedUnitCount = 1
    libraryUpdater.simulateStatusChange(.recentTracks(progress: recentTracksProgress))
    let tagsProgress = Progress()
    tagsProgress.totalUnitCount = 10
    tagsProgress.completedUnitCount = 1
    libraryUpdater.simulateStatusChange(.tags(artistName: "Artist", progress: tagsProgress))

    let expectedStatuses = ["Getting library...".unlocalized,
                            "Getting library: page 1 out of 10".unlocalized,
                            "Getting recent tracks...".unlocalized,
                            "Getting recent tracks: page 1 out of 10".unlocalized,
                            "Getting tags for artists: 1 out of 10".unlocalized]
    expect(statuses).to(equal(expectedStatuses))
  }

  private func writeArtists() {
    let realmArtists = sampleArtists.map { RealmArtist.from(transient: $0) }
    realm.beginWrite()
    realm.add(realmArtists)
    try? realm.commitWrite()
  }
}
