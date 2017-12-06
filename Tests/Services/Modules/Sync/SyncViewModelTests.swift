//
//  SyncViewModelTests.swift
//  MementoFMTests
//
//  Created by Daniel on 01/12/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble

class SyncViewModelTests: XCTestCase {
  class Dependencies: HasLibraryUpdater {
    let libraryUpdater: LibraryUpdaterProtocol

    init(libraryUpdater: LibraryUpdaterProtocol) {
      self.libraryUpdater = libraryUpdater
    }
  }

  class StubSyncViewModelDelegate: SyncViewModelDelegate {
    var didFinishLoading = false
    func syncViewModelDidFinishLoading(_ viewModel: SyncViewModel) {
      didFinishLoading = true
    }
  }

  var libraryUpdater: StubLibraryUpdater!
  var dependencies: Dependencies!

  override func setUp() {
    super.setUp()

    libraryUpdater = StubLibraryUpdater()
    dependencies = Dependencies(libraryUpdater: libraryUpdater)
  }

  func testSyncingLibrary() {
    let viewModel = SyncViewModel(dependencies: dependencies)

    viewModel.syncLibrary()
    expect(self.libraryUpdater.didCancelPendingRequests).to(beTrue())
    expect(self.libraryUpdater.didRequestData).to(beTrue())
  }

  func testSyncStatusChange() {
    let viewModel = SyncViewModel(dependencies: dependencies)

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

    // Not sure if this is the good way to test this conversion (strings may be localized in the future)
    let expectedStatuses = ["Updating library...".unlocalized,
                            "Updating library (page 1 out of 10)".unlocalized,
                            "Getting recent tracks...".unlocalized,
                            "Getting recent tracks (page 1 out of 10)".unlocalized,
                            "Getting tags for\nArtist\n(1 out of 10)".unlocalized]
    expect(statuses).to(equal(expectedStatuses))
  }

  func testSyncFinishedWithSuccess() {
    let viewModel = SyncViewModel(dependencies: dependencies)
    let delegate = StubSyncViewModelDelegate()
    viewModel.delegate = delegate

    libraryUpdater.simulateFinishLoading()
    expect(delegate.didFinishLoading).to(beTrue())
  }

  func testSyncFinishedWithError() {
    let viewModel = SyncViewModel(dependencies: dependencies)
    var expectedError: Error?
    viewModel.onDidReceiveError = { error in
      expectedError = error
    }

    libraryUpdater.simulateError(NSError(domain: "MementoFM", code: 6, userInfo: nil))
    expect(expectedError).toNot(beNil())
  }
}
