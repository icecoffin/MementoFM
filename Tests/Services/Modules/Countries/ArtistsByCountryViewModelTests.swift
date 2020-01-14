//
//  ArtistsByCountryViewModelTests.swift
//  MementoFMTests
//
//  Created by Dani on 13.01.2020.
//  Copyright © 2020 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble

class ArtistsByCountryViewModelTests: XCTestCase {
  class Dependencies: HasArtistService {
    let artistService: ArtistServiceProtocol

    init(artistService: ArtistServiceProtocol) {
      self.artistService = artistService
    }
  }

  class StubArtistsByCountryViewModelDelegate: ArtistListViewModelDelegate {
    var selectedArtist: Artist?
    func artistListViewModel(_ viewModel: ArtistListViewModel, didSelectArtist artist: Artist) {
      selectedArtist = artist
    }
  }

  var collection: MockPersistentMappedCollection<Artist>!
  var artistService: StubArtistService!
  var dependencies: Dependencies!
  var viewModel: ArtistsByCountryViewModel!

  override func setUp() {
    super.setUp()

    artistService = StubArtistService()
    dependencies = Dependencies(artistService: artistService)
    viewModel = ArtistsByCountryViewModel(country: .named(name: "Germany"), dependencies: dependencies)

    let artists = ModelFactory.generateArtists(inAmount: 10)
    collection = MockPersistentMappedCollection<Artist>(values: artists)
    artistService.customMappedCollection = AnyPersistentMappedCollection(collection)
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
    let delegate = StubArtistsByCountryViewModelDelegate()
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

  func test_performSearch_callsDidUpdateData() {
    var didUpdateData = false
    viewModel.didUpdateData = { _ in
      didUpdateData = true
    }

    viewModel.performSearch(withText: "test")

    expect(didUpdateData) == true
  }
}
