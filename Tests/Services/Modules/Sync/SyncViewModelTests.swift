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

    func test_syncLibrary_cancelsPendingRequestsAndRequestsDataOnLibraryUpdater() {
        let viewModel = SyncViewModel(dependencies: dependencies)

        viewModel.syncLibrary()

        expect(self.libraryUpdater.didCancelPendingRequests).to(beTrue())
        expect(self.libraryUpdater.didRequestData).to(beTrue())
    }

    func test_didChangeStatus_isCalledWithCorrectStatus_whenLibraryUpdaterChangesStatus() {
        let viewModel = SyncViewModel(dependencies: dependencies)

        var statuses: [String] = []
        viewModel.didChangeStatus = { status in
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

        let expectedStatuses = ["Updating library...",
                                "Updating library (page 1 out of 10)",
                                "Getting recent tracks...",
                                "Getting recent tracks (page 1 out of 10)",
                                "Getting tags for\nArtist\n(1 out of 10)"]

        expect(statuses).to(equal(expectedStatuses))
    }

    func test_didFinishLoading_isCalledOnDelegate_whenLibraryUpdaterFinishesLoading() {
        let viewModel = SyncViewModel(dependencies: dependencies)
        let delegate = StubSyncViewModelDelegate()
        viewModel.delegate = delegate

        libraryUpdater.simulateFinishLoading()
        expect(delegate.didFinishLoading).to(beTrue())
    }

    func test_didReceiveError_isCalled_whenLibraryUpdaterFinishesWithError() {
        let viewModel = SyncViewModel(dependencies: dependencies)
        var expectedError: Error?
        viewModel.didReceiveError = { error in
            expectedError = error
        }

        libraryUpdater.simulateError(NSError(domain: "MementoFM", code: 6, userInfo: nil))
        expect(expectedError).toNot(beNil())
    }
}
