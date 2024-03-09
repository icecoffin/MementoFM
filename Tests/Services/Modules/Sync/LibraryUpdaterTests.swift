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
import Combine

final class LibraryUpdaterTests: XCTestCase {
    private var userService: MockUserService!
    private var artistService: MockArtistService!
    private var tagService: MockTagService!
    private var ignoredTagService: MockIgnoredTagService!
    private var trackService: MockTrackService!
    private var countryService: MockCountryService!
    private var networkService: MockNetworkService!
    private var cancelBag: Set<AnyCancellable>!

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
        cancelBag = .init()
    }

    override func tearDown() {
        userService = nil
        artistService = nil
        tagService = nil
        ignoredTagService = nil
        trackService = nil
        countryService = nil
        networkService = nil
        cancelBag = nil

        super.tearDown()
    }

    func test_lastUpdateTimestamp_returnsValueFromUserService() {
        let libraryUpdater = makeLibraryUpdater()

        userService.lastUpdateTimestamp = 100

        expect(libraryUpdater.lastUpdateTimestamp) == 100
    }

    func test_requestData_startsAndFinishesLoading() {
        let libraryUpdater = makeLibraryUpdater()

        var loadingStates: [Bool] = []

        libraryUpdater.isLoading
            .sink(receiveValue: { isLoading in
                loadingStates.append(isLoading)
            })
            .store(in: &cancelBag)

        libraryUpdater.requestData()

        expect(loadingStates) == [true, false]
    }

    func test_requestData_setsIsFirstUpdateToFalse() {
        let libraryUpdater = makeLibraryUpdater()

        libraryUpdater.requestData()

        expect(libraryUpdater.isFirstUpdate) == false
    }

    func test_requestData_emitsError() {
        let libraryUpdater = makeLibraryUpdater()

        var didReceiveError = false
        libraryUpdater.error
            .sink(receiveValue: { _ in
                didReceiveError = true
            })
            .store(in: &cancelBag)

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

        libraryUpdater.status
            .sink(receiveValue: { status in
                libraryUpdateStatus = status
            })
            .store(in: &cancelBag)

        libraryUpdater.cancelPendingRequests()

        expect {
            guard let status = libraryUpdateStatus, case .artistsFirstPage = status else {
                return { .failed(reason: "libraryUpdateStatus is nil or wrong enum case") }
            }
            return { .succeeded }
        }.to(succeed())
    }

    private func makeLibraryUpdater() -> LibraryUpdater {
        return LibraryUpdater(
            userService: userService,
            artistService: artistService,
            tagService: tagService,
            ignoredTagService: ignoredTagService,
            trackService: trackService,
            countryService: countryService,
            networkService: networkService
        )
    }
}
