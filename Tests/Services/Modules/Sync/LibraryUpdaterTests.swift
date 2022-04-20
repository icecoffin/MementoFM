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
    var userService: MockUserService!
    var artistService: MockArtistService!
    var tagService: MockTagService!
    var ignoredTagService: MockIgnoredTagService!
    var trackService: MockTrackService!
    var countryService: MockCountryService!
    var networkService: MockNetworkService!

    override func setUp() {
        super.setUp()

        userService = MockUserService()
        artistService = MockArtistService()
        tagService = MockTagService()
        ignoredTagService = MockIgnoredTagService()
        trackService = MockTrackService()
        countryService = MockCountryService()
        networkService = MockNetworkService()
        networkService.customResponse = EmptyResponse()
    }

    override func tearDown() {
        super.tearDown()
    }

    func test_lastUpdateTimestamp_returnsValueFromUserService() {
        let libraryUpdater = makeLibraryUpdater()

        userService.lastUpdateTimestamp = 100

        expect(libraryUpdater.lastUpdateTimestamp) == 100
    }

    func test_requestData_callsDidStartLoading() {
        let libraryUpdater = makeLibraryUpdater()

        var didStartLoading = false

        libraryUpdater.didStartLoading = {
            didStartLoading = true
        }

        libraryUpdater.requestData()

        expect(didStartLoading) == true
    }

    func test_requestData_callsDidFinishLoading() {
        let libraryUpdater = makeLibraryUpdater()

        var didFinishLoading = false

        libraryUpdater.didFinishLoading = {
            didFinishLoading = true
        }

        libraryUpdater.requestData()

        expect(didFinishLoading) == true
    }

    func test_requestData_setsIsFirstUpdateToFalse() {
        let libraryUpdater = makeLibraryUpdater()

        libraryUpdater.requestData()

        expect(libraryUpdater.isFirstUpdate) == false
    }

    func test_requestData_callsDidReceiveError_whenFinishedWithError() {
        let libraryUpdater = makeLibraryUpdater()

        var didReceiveError = false
        libraryUpdater.didReceiveError = { _ in
            didReceiveError = true
        }

        artistService.getLibraryShouldReturnError = true

        libraryUpdater.requestData()

        expect(didReceiveError) == true
    }

    func test_requestData_updatesLastUpdateTimestamp() {
        let libraryUpdater = makeLibraryUpdater()

        userService.didReceiveInitialCollection = true

        libraryUpdater.requestData()

        expect(self.userService.lastUpdateTimestamp) > 0
    }

    func test_requestData_getsRecentTracksAndProcessesThem() {
        let libraryUpdater = makeLibraryUpdater()

        userService.didReceiveInitialCollection = true

        libraryUpdater.requestData()

        expect(self.trackService.didCallGetRecentTracks) == true
        expect(self.trackService.didCallProcessTracks) == true
    }

    func test_requestsData_requestsInitialCollectionAndSavesIt() {
        let libraryUpdater = makeLibraryUpdater()

        userService.didReceiveInitialCollection = false
        libraryUpdater.requestData()

        expect(self.artistService.didRequestLibrary) == true
        expect(self.userService.didReceiveInitialCollection) == true
        expect(self.artistService.didCallSaveArtists) == true
    }

    func test_requestData_requestsArtistsTagsDuringLibraryUpdate() {
        artistService.customArtistsNeedingTagsUpdate = ModelFactory.generateArtists(inAmount: 10)
        ignoredTagService.customIgnoredTags = ModelFactory.generateIgnoredTags(inAmount: 10)

        let libraryUpdater = makeLibraryUpdater()

        let progress = Progress()
        progress.totalUnitCount = 1
        progress.completedUnitCount = 1
        let artist = ModelFactory.generateArtist()
        let topTagsList = TopTagsList(tags: ModelFactory.generateTags(inAmount: 10, for: artist.name))
        tagService.customTopTagsPages = [TopTagsPage(artist: artist, topTagsList: topTagsList)]

        libraryUpdater.requestData()

        expect(self.artistService.didRequestArtistsNeedingTagsUpdate) == true
        expect(self.tagService.didRequestTopTags) == true
        expect(self.artistService.didCallUpdateArtist) == true
        expect(self.artistService.didCallCalculateTopTags) == true
    }

    func test_cancelPendingRequests_changesStatusToArtistsFirstPage() {
        let libraryUpdater = makeLibraryUpdater()
        var libraryUpdateStatus: LibraryUpdateStatus!

        libraryUpdater.didChangeStatus = { status in
            libraryUpdateStatus = status
        }

        libraryUpdater.cancelPendingRequests()

        expect {
            guard let status = libraryUpdateStatus, case .artistsFirstPage = status else {
                return { .failed(reason: "libraryUpdateStatus is nil or wrong enum case") }
            }
            return { .succeeded }
        }.to(succeed())
    }

    private func makeLibraryUpdater() -> LibraryUpdater {
        return LibraryUpdater(userService: userService,
                              artistService: artistService,
                              tagService: tagService,
                              ignoredTagService: ignoredTagService,
                              trackService: trackService,
                              countryService: countryService,
                              networkService: networkService)
    }
}
