//
//  SyncViewModelTests.swift
//  MementoFMTests
//
//  Created by Daniel on 01/12/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest

import Combine
@testable import MementoFM

final class SyncViewModelTests: XCTestCase {
    private final class Dependencies: HasLibraryUpdater {
        let libraryUpdater: LibraryUpdaterProtocol

        init(libraryUpdater: LibraryUpdaterProtocol) {
            self.libraryUpdater = libraryUpdater
        }
    }

    private final class TestSyncViewModelDelegate: SyncViewModelDelegate {
        var didFinishLoading = false
        func syncViewModelDidFinishLoading(_ viewModel: SyncViewModel) {
            didFinishLoading = true
        }
    }

    private var libraryUpdater: MockLibraryUpdater!
    private var dependencies: Dependencies!
    private var cancelBag: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()

        libraryUpdater = MockLibraryUpdater()
        dependencies = Dependencies(libraryUpdater: libraryUpdater)
        cancelBag = .init()
    }

    override func tearDown() {
        libraryUpdater = nil
        dependencies = nil
        cancelBag = nil

        super.tearDown()
    }

    func test_syncLibrary_cancelsPendingRequestsAndRequestsDataOnLibraryUpdater() {
        let viewModel = SyncViewModel(dependencies: dependencies)

        viewModel.syncLibrary()

        XCTAssertTrue(libraryUpdater.didCancelPendingRequests)
        XCTAssertTrue(libraryUpdater.didRequestData)
    }

    func test_status_isUpdatedCorrectly_whenLibraryUpdaterChangesStatus() {
        let viewModel = SyncViewModel(dependencies: dependencies)

        var statuses: [String] = []
        viewModel.status
            .sink(receiveValue: { status in
                statuses.append(status)
            })
            .store(in: &cancelBag)

        libraryUpdater.simulateStatusChange(.artistsFirstPage)

        let artistsProgress = PageProgress(current: 1, total: 10)
        libraryUpdater.simulateStatusChange(.artists(progress: artistsProgress))

        libraryUpdater.simulateStatusChange(.recentTracksFirstPage)

        let recentTracksProgress = PageProgress(current: 1, total: 10)
        libraryUpdater.simulateStatusChange(.recentTracks(progress: recentTracksProgress))

        let tagsProgress = PageProgress(current: 1, total: 10)
        libraryUpdater.simulateStatusChange(.tags(artistName: "Artist", progress: tagsProgress))

        let expectedStatuses = ["Updating library...",
                                "Updating library (page 1 out of 10)",
                                "Getting recent tracks...",
                                "Getting recent tracks (page 1 out of 10)",
                                "Getting tags for\nArtist\n(1 out of 10)"]

        XCTAssertEqual(statuses, expectedStatuses)
    }

    func test_didFinishLoading_isCalledOnDelegate_whenLibraryUpdaterFinishesLoading() {
        let viewModel = SyncViewModel(dependencies: dependencies)
        let delegate = TestSyncViewModelDelegate()
        viewModel.delegate = delegate

        libraryUpdater.simulateFinishLoading()
        XCTAssertTrue(delegate.didFinishLoading)
    }

    func test_error_isEmittedWhenLibraryUpdaterFinishesWithError() {
        let viewModel = SyncViewModel(dependencies: dependencies)
        var expectedError: Error?
        viewModel.error
            .sink(receiveValue: { error in
                expectedError = error
            })
            .store(in: &cancelBag)

        libraryUpdater.simulateError(NSError(domain: "MementoFM", code: 6, userInfo: nil))
        XCTAssertNotNil(expectedError)
    }
}
