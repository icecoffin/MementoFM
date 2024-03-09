//
//  ArtistSimilarsSectionViewModelTests.swift
//  MementoFMTests
//
//  Created by Daniel on 07/12/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble
import Combine

final class ArtistSimilarsSectionViewModelTests: XCTestCase {
    private final class Dependencies: ArtistSimilarsSectionViewModel.Dependencies {
        let artistService: ArtistServiceProtocol

        init(artistService: ArtistServiceProtocol) {
            self.artistService = artistService
        }
    }

    // swiftlint:disable:next type_name
    private final class TestArtistSimilarsSectionViewModelDelegate: ArtistSimilarsSectionViewModelDelegate {
        var didCallDidSelectArtist = false
        func artistSimilarsSectionViewModel(_ viewModel: ArtistSimilarsSectionViewModel, didSelectArtist artist: Artist) {
            didCallDidSelectArtist = true
        }
    }

    private let sampleArtist = ModelFactory.generateArtist()

    private var artistService: MockArtistService!
    private var dependencies: Dependencies!
    private var tabViewModelFactory: MockArtistSimilarsSectionTabViewModelFactory!
    private var cancelBag: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()

        artistService = MockArtistService()
        tabViewModelFactory = MockArtistSimilarsSectionTabViewModelFactory()
        dependencies = Dependencies(artistService: artistService)
        cancelBag = .init()
    }

    override func tearDown() {
        artistService = nil
        tabViewModelFactory = nil
        dependencies = nil
        cancelBag = nil

        super.tearDown()
    }

    func test_currentTabViewModel_returnsFirstTabAfterInit() {
        let artist = sampleArtist
        let viewModel = ArtistSimilarsSectionViewModel(
            artist: artist,
            dependencies: dependencies,
            tabViewModelFactory: tabViewModelFactory
        )

        expect(viewModel.currentTabViewModel).to(beIdenticalTo(tabViewModelFactory.firstTabViewModel))
    }

    func test_numberOfSimilarArtists_returnsValueFromCurrentTabViewModel() {
        let artist = sampleArtist
        let viewModel = ArtistSimilarsSectionViewModel(
            artist: artist,
            dependencies: dependencies,
            tabViewModelFactory: tabViewModelFactory
        )

        tabViewModelFactory.firstTabViewModel.numberOfSimilarArtists = 5

        expect(viewModel.numberOfSimilarArtists) == 5
    }

    func test_hasSimilarArtists_returnsValueFromCurrentTabViewModel() {
        let artist = sampleArtist
        let viewModel = ArtistSimilarsSectionViewModel(
            artist: artist,
            dependencies: dependencies,
            tabViewModelFactory: tabViewModelFactory
        )

        tabViewModelFactory.firstTabViewModel.hasSimilarArtists = true

        expect(viewModel.hasSimilarArtists) == true
    }

    func test_isLoading_returnsValueFromCurrentTabViewModel() {
        let artist = sampleArtist
        let viewModel = ArtistSimilarsSectionViewModel(
            artist: artist,
            dependencies: dependencies,
            tabViewModelFactory: tabViewModelFactory
        )

        tabViewModelFactory.firstTabViewModel.isLoading = true

        expect(viewModel.isLoading) == true
    }

    func test_emptyDataSetText_returnsValueFromCurrentTabViewModel() {
        let artist = sampleArtist
        let viewModel = ArtistSimilarsSectionViewModel(
            artist: artist,
            dependencies: dependencies,
            tabViewModelFactory: tabViewModelFactory
        )

        tabViewModelFactory.firstTabViewModel.emptyDataSetText = "Test"

        expect(viewModel.emptyDataSetText) == "Test"
    }

    func test_getSimilarArtists_callsMethodOnCurrentTabViewModel() {
        let artist = sampleArtist
        let viewModel = ArtistSimilarsSectionViewModel(
            artist: artist,
            dependencies: dependencies,
            tabViewModelFactory: tabViewModelFactory
        )

        viewModel.getSimilarArtists()

        expect(self.tabViewModelFactory.firstTabViewModel.didCallGetSimilarArtists) == true
    }

    func test_cellViewModelAtIndexPath_callsMethodOnCurrentTabViewModel() {
        let artist = sampleArtist
        let viewModel = ArtistSimilarsSectionViewModel(
            artist: artist,
            dependencies: dependencies,
            tabViewModelFactory: tabViewModelFactory
        )
        let cellViewModel = SimilarArtistCellViewModel(artist: sampleArtist, commonTags: [], index: 1)

        tabViewModelFactory.firstTabViewModel.customCellViewModel = cellViewModel
        let indexPath = IndexPath(row: 0, section: 0)
        _ = viewModel.cellViewModel(at: indexPath)

        expect(self.tabViewModelFactory.firstTabViewModel.cellViewModelIndexPath) == indexPath
    }

    func test_selectArtistAtIndexPath_callsMethodOnCurrentTabViewModel() {
        let artist = sampleArtist
        let viewModel = ArtistSimilarsSectionViewModel(
            artist: artist,
            dependencies: dependencies,
            tabViewModelFactory: tabViewModelFactory
        )

        let indexPath = IndexPath(row: 0, section: 0)
        viewModel.selectArtist(at: indexPath)

        expect(self.tabViewModelFactory.firstTabViewModel.selectedArtistIndexPath) == indexPath
    }

    func test_selectTabAtIndex_changesCurrentTabViewModel() {
        let artist = sampleArtist
        let viewModel = ArtistSimilarsSectionViewModel(
            artist: artist,
            dependencies: dependencies,
            tabViewModelFactory: tabViewModelFactory
        )

        viewModel.selectTab(at: 1)

        expect(viewModel.currentTabViewModel).to(beIdenticalTo(tabViewModelFactory.secondTabViewModel))
    }

    func test_didUpdate_isEmitted_whenTabViewModelUpdatesData() {
        let artist = sampleArtist
        let viewModel = ArtistSimilarsSectionViewModel(
            artist: artist,
            dependencies: dependencies,
            tabViewModelFactory: tabViewModelFactory
        )

        var didUpdate = false
        viewModel.didUpdate
            .sink(receiveValue: { _ in didUpdate = true })
            .store(in: &cancelBag)

        tabViewModelFactory.firstTabViewModel.didUpdateSubject.send(.success(()))

        expect(didUpdate) == true
    }

    func test_didUpdate_isEmittedWithError_whenCurrentTabViewModelReceivesError() {
        let artist = sampleArtist
        let viewModel = ArtistSimilarsSectionViewModel(
            artist: artist,
            dependencies: dependencies,
            tabViewModelFactory: tabViewModelFactory
        )

        var didReceiveError = false
        viewModel.didUpdate
            .sink(receiveValue: { result in
                switch result {
                case .success:
                    fail()
                case .failure:
                    didReceiveError = true
                }
            })
            .store(in: &cancelBag)

        let error = NSError(domain: "MementoFM", code: 6, userInfo: nil)
        tabViewModelFactory.firstTabViewModel.didUpdateSubject.send(.failure(error))

        expect(didReceiveError) == true
    }

    func test_selectArtist_onTabViewModel_notifiesDelegateCorrectly() {
        let artist = sampleArtist
        let viewModel = ArtistSimilarsSectionViewModel(
            artist: artist,
            dependencies: dependencies,
            tabViewModelFactory: tabViewModelFactory
        )
        let delegate = TestArtistSimilarsSectionViewModelDelegate()
        viewModel.delegate = delegate

        let requestStrategy = SimilarArtistsLocalRequestStrategy(dependencies: dependencies)
        let tabViewModel = SimilarsSectionTabViewModel(
            artist: artist,
            canSelectSimilarArtists: true,
            requestStrategy: requestStrategy,
            dependencies: dependencies
        )

        viewModel.similarsSectionTabViewModel(tabViewModel, didSelectArtist: artist)

        expect(delegate.didCallDidSelectArtist) == true
    }

    func test_canSelectSimilarArtists_returnsValueFromCurrentTabViewModel() {
        let artist = sampleArtist
        let viewModel = ArtistSimilarsSectionViewModel(
            artist: artist,
            dependencies: dependencies,
            tabViewModelFactory: tabViewModelFactory
        )

        tabViewModelFactory.firstTabViewModel.canSelectSimilarArtists = true

        expect(viewModel.canSelectSimilarArtists) == true
    }
}
