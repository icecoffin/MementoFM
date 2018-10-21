//
//  LibraryUpdaterTests.swift
//  MementoFMTests
//
//  Created by Daniel on 04/12/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble

class LibraryUpdaterTests: XCTestCase {
  var userService: StubUserService!
  var artistService: StubArtistService!
  var tagService: StubTagService!
  var ignoredTagService: StubIgnoredTagService!
  var trackService: StubTrackService!
  var networkService: StubNetworkService<EmptyResponse>!

  override func setUp() {
    super.setUp()
    userService = StubUserService()
    artistService = StubArtistService()
    tagService = StubTagService()
    ignoredTagService = StubIgnoredTagService()
    trackService = StubTrackService()
    networkService = StubNetworkService(response: EmptyResponse())
  }

  override func tearDown() {
    super.tearDown()
  }

  func test_lastUpdateTimestamp_returnsValueFromUserService() {
    let libraryUpdater = makeLibraryUpdater()

    userService.lastUpdateTimestamp = 100

    expect(libraryUpdater.lastUpdateTimestamp).to(equal(100))
  }

  func test_requestData_callsOnDidStartLoading() {
    let libraryUpdater = makeLibraryUpdater()

    var didStartLoading = false

    libraryUpdater.onDidStartLoading = {
      didStartLoading = true
    }

    libraryUpdater.requestData()

    expect(didStartLoading).to(beTrue())
  }

  func test_requestData_callsOnDidFinishLoading() {
    let libraryUpdater = makeLibraryUpdater()

    var didFinishLoading = false

    libraryUpdater.onDidFinishLoading = {
      didFinishLoading = true
    }

    libraryUpdater.requestData()

    expect(didFinishLoading).toEventually(beTrue())
  }

  func test_requestData_setsIsFirstUpdateToFalse() {
    let libraryUpdater = makeLibraryUpdater()

    libraryUpdater.requestData()

    expect(libraryUpdater.isFirstUpdate).toEventually(beFalse())
  }

  func test_requestData_callsOnDidReceiveError_whenFinishedWithError() {
    let libraryUpdater = makeLibraryUpdater()

    var didReceiveError = false
    libraryUpdater.onDidReceiveError = { _ in
      didReceiveError = true
    }

    artistService.getLibraryShouldReturnError = true

    libraryUpdater.requestData()

    expect(didReceiveError).toEventually(equal(true))
  }

  func test_requestData_updatesLastUpdateTimestamp() {
    let libraryUpdater = makeLibraryUpdater()

    userService.didReceiveInitialCollection = true

    libraryUpdater.requestData()

    expect(self.userService.lastUpdateTimestamp).toEventually(beGreaterThan(0))
  }

  func test_requestData_getsRecentTracksAndProcessesThem() {
    let libraryUpdater = makeLibraryUpdater()

    userService.didReceiveInitialCollection = true

    libraryUpdater.requestData()

    expect(self.trackService.didCallGetRecentTracks).toEventually(beTrue())
    expect(self.trackService.didCallProcessTracks).toEventually(beTrue())
  }

  func test_requestsData_requestsInitialCollectionAndSavesIt() {
    let libraryUpdater = makeLibraryUpdater()

    userService.didReceiveInitialCollection = false
    libraryUpdater.requestData()

    expect(self.artistService.didRequestLibrary).toEventually(beTrue())
    expect(self.userService.didReceiveInitialCollection).toEventually(beTrue())
    expect(self.artistService.didCallSaveArtists).toEventually(beTrue())
  }

  func test_requestData_requestsArtistsTagsDuringLibraryUpdate() {
    let libraryUpdater = makeLibraryUpdater()

    let progress = Progress()
    progress.totalUnitCount = 1
    progress.completedUnitCount = 1
    let artist = ModelFactory.generateArtist()
    let topTagsList = TopTagsList(tags: ModelFactory.generateTags(inAmount: 10, for: artist.name))
    let topTagsRequestProgress = TopTagsRequestProgress(progress: progress, artist: artist, topTagsList: topTagsList)
    tagService.stubProgress = topTagsRequestProgress

    libraryUpdater.requestData()

    expect(self.artistService.didRequestArtistsNeedingTagsUpdate).toEventually(beTrue())
    expect(self.tagService.didRequestTopTags).toEventually(beTrue())
    expect(self.artistService.didCallUpdateArtist).toEventually(beTrue())
    expect(self.artistService.didCallCalculateTopTags).toEventually(beTrue())
  }

  func test_cancelPendingRequests_changesStatusToArtistsFirstPage() {
    let libraryUpdater = makeLibraryUpdater()
    var libraryUpdateStatus: LibraryUpdateStatus!

    libraryUpdater.onDidChangeStatus = { status in
      libraryUpdateStatus = status
    }

    libraryUpdater.cancelPendingRequests()

    expect(self.networkService.didCancelPendingRequests).to(beTrue())
    expect({
      guard let status = libraryUpdateStatus, case .artistsFirstPage = status else {
        return .failed(reason: "libraryUpdateStatus is nil or wrong enum case")
      }
      return .succeeded
    }).to(succeed())
  }

  private func makeLibraryUpdater() -> LibraryUpdater {
    return LibraryUpdater(userService: userService,
                          artistService: artistService,
                          tagService: tagService,
                          ignoredTagService: ignoredTagService,
                          trackService: trackService,
                          networkService: networkService)
  }
}
