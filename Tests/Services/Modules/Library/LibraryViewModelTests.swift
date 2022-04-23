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

final class LibraryViewModelTests: XCTestCase {
    private final class Dependencies: LibraryViewModel.Dependencies {
        let libraryUpdater: LibraryUpdaterProtocol
        let artistService: ArtistServiceProtocol
        let userService: UserServiceProtocol

        init(libraryUpdater: LibraryUpdaterProtocol, artistService: ArtistServiceProtocol, userService: UserServiceProtocol) {
            self.libraryUpdater = libraryUpdater
            self.artistService = artistService
            self.userService = userService
        }
    }

    private final class TestLibraryViewModelDelegate: ArtistListViewModelDelegate {
        var selectedArtist: Artist?
        func artistListViewModel(_ viewModel: ArtistListViewModel, didSelectArtist artist: Artist) {
            selectedArtist = artist
        }
    }

    private final class MockApplicationStateObserver: ApplicationStateObserving {
        private(set) var applicationDidBecomeActiveSubject = PassthroughSubject<Void, Never>()

        var applicationDidBecomeActive: AnyPublisher<Void, Never> {
            return applicationDidBecomeActiveSubject.eraseToAnyPublisher()
        }
    }

    private var libraryUpdater: MockLibraryUpdater!
    private var collection: MockPersistentMappedCollection<Artist>!
    private var artistService: MockArtistService!
    private var userService: MockUserService!
    private var dependencies: Dependencies!
    private var cancelBag: Set<AnyCancellable>!

    private var sampleArtists: [Artist] = {
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
        cancelBag = .init()
    }

    override func tearDown() {
        libraryUpdater = nil
        collection = nil
        artistService = nil
        userService = nil
        dependencies = nil
        cancelBag = nil

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
        viewModel.didUpdate
            .sink(receiveValue: { _ in
                didUpdateData = true
            })
            .store(in: &cancelBag)

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

    func test_isLoading_isChangedOnLibraryUpdate() {
        let viewModel = LibraryViewModel(dependencies: dependencies)
        var loadingStates: [Bool] = []
        viewModel.isLoading
            .sink(receiveValue: { isLoading in
                loadingStates.append(isLoading)
            })
            .store(in: &cancelBag)

        libraryUpdater.simulateStartLoading()
        libraryUpdater.simulateFinishLoading()

        expect(loadingStates) == [true, false]
    }

    // MARK: - didReceiveError

    func test_didReceiveError_isCalledOnLibraryUpdateError() {
        let viewModel = LibraryViewModel(dependencies: dependencies)
        var didReceiveError = false
        viewModel.didUpdate
            .sink(receiveValue: { result in
                if case .failure = result {
                    didReceiveError = true
                }
            })
            .store(in: &cancelBag)

        libraryUpdater.simulateError(NSError(domain: "MementoFM", code: 6, userInfo: nil))

        expect(didReceiveError) == true
    }

    // MARK: - didChangeStatus

    func test_didChangeStatus_isCalledWithCorrectStatus_whenStatusChanges() {
        let viewModel = LibraryViewModel(dependencies: dependencies)
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

        let expectedStatuses = ["Getting library...",
                                "Getting library: page 1 out of 10",
                                "Getting recent tracks...",
                                "Getting recent tracks: page 1 out of 10",
                                "Getting tags for artists: 1 out of 10"]
        expect(statuses) == expectedStatuses
    }
}
