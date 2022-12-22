//
//  ArtistsByCountryViewModelTests.swift
//  MementoFMTests
//
//  Created by Dani on 13.01.2020.
//  Copyright © 2020 icecoffin. All rights reserved.
//

import XCTest
import Nimble
import Combine
import TransientModels
@testable import MementoFM

final class ArtistsByCountryViewModelTests: XCTestCase {
    private final class Dependencies: HasArtistService {
        let artistService: ArtistServiceProtocol

        init(artistService: ArtistServiceProtocol) {
            self.artistService = artistService
        }
    }

    private final class TestArtistsByCountryViewModelDelegate: ArtistListViewModelDelegate {
        var selectedArtist: Artist?
        func artistListViewModel(_ viewModel: ArtistListViewModel, didSelectArtist artist: Artist) {
            selectedArtist = artist
        }
    }

    private var collection: MockPersistentMappedCollection<Artist>!
    private var artistService: MockArtistService!
    private var dependencies: Dependencies!
    private var viewModel: ArtistsByCountryViewModel!
    private var cancelBag: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()

        artistService = MockArtistService()
        dependencies = Dependencies(artistService: artistService)
        viewModel = ArtistsByCountryViewModel(country: .named(name: "Germany"), dependencies: dependencies)
        cancelBag = .init()

        let artists = ModelFactory.generateArtists(inAmount: 10)
        collection = MockPersistentMappedCollection<Artist>(values: artists)
        artistService.customMappedCollection = AnyPersistentMappedCollection(collection)
    }

    override func tearDown() {
        collection = nil
        artistService = nil
        dependencies = nil
        viewModel = nil
        cancelBag = nil

        super.tearDown()
    }

    // MARK: - itemCount

    func test_itemCount_returnsCorrectValue() {
        collection.customCount = 5

        expect(self.viewModel.itemCount) == 5
    }

    // MARK: - title

    func test_title_returnsCorrectValue() {
        expect(self.viewModel.title) == "Germany"
    }

    // MARK: - artistViewModel(at:)

    func test_artistViewModelAtIndexPath_returnsCorrectValue() {
        let indexPath = IndexPath(row: 0, section: 0)
        let artistViewModel = viewModel.artistViewModel(at: indexPath)

        expect(artistViewModel.name) == "Artist1"
    }

    // MARK: - selectArtist(at:)

    func test_selectArtistAtIndexPath_notifiesDelegate() {
        let delegate = TestArtistsByCountryViewModelDelegate()
        viewModel.delegate = delegate

        let indexPath = IndexPath(row: 0, section: 0)
        viewModel.selectArtist(at: indexPath)

        expect(delegate.selectedArtist?.name) == "Artist1"
    }

    // MARK: - performSearch

    func test_performSearch_setsCorrectPredicate_forNamedCountry() {
        viewModel.performSearch(withText: "test")

        let predicateFormat = artistService.customMappedCollection.predicate?.predicateFormat
        expect(predicateFormat) == "country == \"Germany\" AND name CONTAINS[cd] \"test\""
    }

    func test_performSearch_setsCorrectPredicate_forUnknownCountry() {
        viewModel = ArtistsByCountryViewModel(country: .unknown, dependencies: dependencies)

        viewModel.performSearch(withText: "test")

        let predicateFormat = artistService.customMappedCollection.predicate?.predicateFormat
        expect(predicateFormat) == "(country == nil OR country == \"\") AND name CONTAINS[cd] \"test\""
    }

    func test_performSearch_callsDidUpdate() {
        var didUpdateData = false
        viewModel.didUpdate
            .sink(receiveValue: { _ in
                didUpdateData = true
            })
            .store(in: &cancelBag)

        viewModel.performSearch(withText: "test")

        expect(didUpdateData) == true
    }
}
