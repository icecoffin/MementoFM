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
import Combine

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

    class TestLibraryViewModelDelegate: ArtistListViewModelDelegate {
        var selectedArtist: Artist?
        func artistListViewModel(_ viewModel: ArtistListViewModel, didSelectArtist artist: Artist) {
            selectedArtist = artist
        }
    }

    class MockApplicationStateObserver: ApplicationStateObserving {
        private(set) var applicationDidBecomeActiveSubject = PassthroughSubject<Void, Never>()

        var applicationDidBecomeActive: AnyPublisher<Void, Never> {
            return applicationDidBecomeActiveSubject.eraseToAnyPublisher()
        }
    }

    var libraryUpdater: MockLibraryUpdater!
    var collection: MockPersistentMappedCollection<Artist>!
    var artistService: MockArtistService!
    var userService: MockUserService!
    var dependencies: Dependencies!

    var sampleArtists: [Artist] = {
        return [
            Artist(name: "Artist1", playcount: 1, urlString: "", needsTagsUpdate: true, tags: [], topTags: [], country: nil),
            Artist(name: "Artist2", playcount: 1, urlString: "", needsTagsUpdate: true, tags: [], topTags: [], country: nil),
            Artist(name: "Artist3", playcount: 1, urlString: "", needsTagsUpdate: true, tags: [], topTags: [], country: nil),
            Artist(name: "Artist4", playcount: 1, urlString: "", needsTagsUpdate: true, tags: [], topTags: [], country: nil),
            Artist(name: "Artist5", playcount: 1, urlString: "", needsTagsUpdate: true, tags: [], topTags: [], country: nil),
            Artist(name: "Artist6", playcount: 1, urlString: "", needsTagsUpdate: true, tags: [], topTags: [], country: nil),
            Artist(name: "Artist7", playcount: 1, urlString: "", needsTagsUpdate: true, tags: [], topTags: [], country: nil)
        ]
    }()

    override func setUp() {
        super.setUp()

        libraryUpdater = MockLibraryUpdater()
        collection = MockPersistentMappedCollection(values: sampleArtists)
        artistService = MockArtistService()
        artistService.customMappedCollection = AnyPersistentMappedCollection(collection)
        userService = MockUserService()
        dependencies = Dependencies(libraryUpdater: libraryUpdater, artistService: artistService, userService: userService)
    }

    override func tearDown() {
        libraryUpdater = nil
        artistService = nil
        userService = nil
        dependencies = nil
        super.tearDown()
    }

    // MARK: - requestDataIfNeeded

    func test_requestDataIfNeeded_requestsDataOnFirstUpdate() {
        let viewModel = LibraryViewModel(dependencies: dependencies)

        libraryUpdater.isFirstUpdate = true

        viewModel.requestDataIfNeeded()

        expect(self.libraryUpdater.didRequestData) == true
    }

    func test_requestDataIfNeeded_requestsDataAfterMinTimeInterval() {
        let viewModel = LibraryViewModel(dependencies: dependencies)

        libraryUpdater.lastUpdateTimestamp = 100

        viewModel.requestDataIfNeeded(currentTimestamp: 131, minTimeInterval: 30)

        expect(self.libraryUpdater.didRequestData) == true
    }

    func test_requestDataIfNeeded_doesNotRequestDataBeforeMinTimeInterval() {
        let viewModel = LibraryViewModel(dependencies: dependencies)

        libraryUpdater.lastUpdateTimestamp = 100
        libraryUpdater.isFirstUpdate = false

        viewModel.requestDataIfNeeded(currentTimestamp: 110, minTimeInterval: 30)

        expect(self.libraryUpdater.didRequestData) == false
    }

    // MARK: - itemCount

    func test_itemCount_returnsCorrectValue() {
        let viewModel = LibraryViewModel(dependencies: dependencies)

        expect(viewModel.itemCount) == sampleArtists.count
    }

    // MARK: - artistViewModelAtIndexPath

    func test_artistViewModelAtIndexPath_returnsCorrectValue() {
        let viewModel = LibraryViewModel(dependencies: dependencies)
        let indexPath = IndexPath(row: 1, section: 0)

        let artistViewModel = viewModel.artistViewModel(at: indexPath)

        expect(artistViewModel.name) == sampleArtists[1].name
    }

    // MARK: - selectArtistAtIndexPath

    func test_selectArtistAtIndexPath_notifiesDelegate() {
        let viewModel = LibraryViewModel(dependencies: dependencies)
        let delegate = TestLibraryViewModelDelegate()
        viewModel.delegate = delegate
        let indexPath = IndexPath(row: 1, section: 0)

        viewModel.selectArtist(at: indexPath)

        expect(delegate.selectedArtist) == sampleArtists[1]
    }

    // MARK: - performSearch

    func test_performSearch_setsPredicateToNil_ifTextIsEmpty() {
        let viewModel = LibraryViewModel(dependencies: dependencies)

        viewModel.performSearch(withText: "")

        let predicateFormat = artistService.customMappedCollection.predicate?.predicateFormat
        expect(predicateFormat).to(beNil())
    }

    func test_performSearch_setsCorrectPredicate_ifTextIsNotEmpty() {
        let viewModel = LibraryViewModel(dependencies: dependencies)

        viewModel.performSearch(withText: "test")

        let predicateFormat = artistService.customMappedCollection.predicate?.predicateFormat
        expect(predicateFormat) == "name CONTAINS[cd] \"test\""
    }

    func test_performSearch_callsDidUpdateData() {
        let viewModel = LibraryViewModel(dependencies: dependencies)

        var didUpdateData = false
        viewModel.didUpdateData = { _ in
            didUpdateData = true
        }

        viewModel.performSearch(withText: "test")

        expect(didUpdateData) == true
    }

    // MARK: - libraryUpdater

    func test_libraryUpdater_requestsDataOnApplicationDidBecomeActive() {
        let applicationStateObserver = MockApplicationStateObserver()
        let viewModel = LibraryViewModel(dependencies: dependencies, applicationStateObserver: applicationStateObserver)
        // Suppress 'unused variable' warning
        _ = viewModel.delegate

        applicationStateObserver.applicationDidBecomeActiveSubject.send()

        expect(self.libraryUpdater.didRequestData) == true
    }

    // MARK: - didStartLoading

    func test_didStartLoading_isCalledOnLibraryUpdate() {
        let viewModel = LibraryViewModel(dependencies: dependencies)
        var didStartLoading = false
        viewModel.didStartLoading = {
            didStartLoading = true
        }

        libraryUpdater.simulateStartLoading()

        expect(didStartLoading) == true
    }

    // MARK: - didFinishLoading

    func test_didFinishLoading_isCalledWhenLibraryIsUpdated() {
        let viewModel = LibraryViewModel(dependencies: dependencies)
        var didFinishLoading = false
        viewModel.didFinishLoading = {
            didFinishLoading = true
        }

        libraryUpdater.simulateFinishLoading()

        expect(didFinishLoading) == true
    }

    // MARK: - didUpdateData

    func test_didUpdateData_isCalledWhenLibraryIsUpdated() {
        let viewModel = LibraryViewModel(dependencies: dependencies)
        collection.customIsEmpty = true

        var didUpdateData = false
        var dataIsEmpty = false
        viewModel.didUpdateData = { isEmpty in
            didUpdateData = true
            dataIsEmpty = isEmpty
        }

        libraryUpdater.simulateFinishLoading()

        expect(didUpdateData) == true
        expect(dataIsEmpty) == true
    }

    // MARK: - didReceiveError

    func test_didReceiveError_isCalledOnLibraryUpdateError() {
        let viewModel = LibraryViewModel(dependencies: dependencies)
        var didReceiveError = false
        viewModel.didReceiveError = { _ in
            didReceiveError = true
        }

        libraryUpdater.simulateError(NSError(domain: "MementoFM", code: 6, userInfo: nil))

        expect(didReceiveError) == true
    }

    // MARK: - didChangeStatus

    func test_didChangeStatus_isCalledWithCorrectStatus_whenStatusChanges() {
        let viewModel = LibraryViewModel(dependencies: dependencies)
        var statuses: [String] = []

        viewModel.didChangeStatus = { status in
            statuses.append(status)
        }

        libraryUpdater.simulateStatusChange(.artistsFirstPage)

        let artistsProgress = PageProgress(current: 1, total: 10)
        libraryUpdater.simulateStatusChange(.artists(progress: artistsProgress))

        libraryUpdater.simulateStatusChange(.recentTracksFirstPage)

        let recentTracksProgress = PageProgress(current: 1, total: 10)
        libraryUpdater.simulateStatusChange(.recentTracks(progress: recentTracksProgress))

        let tagsProgress = PageProgress(current: 1, total: 10)
        libraryUpdater.simulateStatusChange(.tags(artistName: "Artist", progress: tagsProgress))

        let expectedStatuses = ["Getting library...",
                                "Getting library: page 1 out of 10",
                                "Getting recent tracks...",
                                "Getting recent tracks: page 1 out of 10",
                                "Getting tags for artists: 1 out of 10"]
        expect(statuses) == expectedStatuses
    }
}
