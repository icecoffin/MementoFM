//
//  SimilarsSectionTabViewModelTests.swift
//  MementoFMTests
//
//  Created by Daniel on 10/12/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble

class SimilarsSectionTabViewModelTests: XCTestCase {
  class Dependencies: ArtistSimilarsSectionViewModel.Dependencies {
    let artistService: ArtistServiceProtocol

    init(artistService: ArtistServiceProtocol) {
      self.artistService = artistService
    }
  }

  class StubSimilarsSectionTabViewModelDelegate: SimilarsSectionTabViewModelDelegate {
    var selectedArtist: Artist?
    func similarsSectionTabViewModel(_ viewModel: SimilarsSectionTabViewModel, didSelectArtist artist: Artist) {
      selectedArtist = artist
    }
  }

  var artistService: StubArtistService!
  var dependencies: Dependencies!
  var requestStrategy: StubSimilarArtistsRequestStrategy!

  let sampleArtist: Artist = {
    let tags = [Tag(name: "Tag1", count: 1), Tag(name: "Tag2", count: 1), Tag(name: "Tag3", count: 1)]
    return Artist(name: "Artist",
                  playcount: 1,
                  urlString: "",
                  needsTagsUpdate: false,
                  tags: [],
                  topTags: tags,
                  country: nil)
  }()

  let similarArtists: [Artist] = {
    let tag1 = Tag(name: "Tag1", count: 1)
    let tag2 = Tag(name: "Tag2", count: 1)
    let tag3 = Tag(name: "Tag3", count: 1)

    return [Artist(name: "Artist1", playcount: 1, urlString: "", needsTagsUpdate: false, tags: [],
                   topTags: [tag1, tag2, tag3], country: nil),
            Artist(name: "Artist2", playcount: 2, urlString: "", needsTagsUpdate: false, tags: [],
                   topTags: [tag1, tag2], country: nil),
            Artist(name: "Artist3", playcount: 3, urlString: "", needsTagsUpdate: false, tags: [],
                   topTags: [tag1, tag2], country: nil),
            Artist(name: "Artist4", playcount: 4, urlString: "", needsTagsUpdate: false, tags: [],
                   topTags: [tag1, tag3], country: nil),
            Artist(name: "Artist5", playcount: 1, urlString: "", needsTagsUpdate: false, tags: [],
                   topTags: [tag1], country: nil)]
  }()

  override func setUp() {
    super.setUp()

    artistService = StubArtistService()
    requestStrategy = StubSimilarArtistsRequestStrategy()
    requestStrategy.stubSimilarArtists = similarArtists
    requestStrategy.minNumberOfIntersectingTags = 2
    dependencies = Dependencies(artistService: artistService)
  }

  func test_getSimilarArtists_updatesNumberOfSimilarArtists() {
    let viewModel = SimilarsSectionTabViewModel(artist: sampleArtist,
                                                requestStrategy: requestStrategy,
                                                dependencies: dependencies)
    var expectedNumberOfSimilarArtists = 0
    viewModel.didUpdateData = {
      expectedNumberOfSimilarArtists = viewModel.numberOfSimilarArtists
    }

    viewModel.getSimilarArtists()

    expect(expectedNumberOfSimilarArtists).toEventually(equal(4))
  }

  func test_getSimilarArtists_updatesHasSimilarArtists() {
    let viewModel = SimilarsSectionTabViewModel(artist: sampleArtist,
                                                requestStrategy: requestStrategy,
                                                dependencies: dependencies)
    var expectedHasSimilarArtists = false
    viewModel.didUpdateData = {
      expectedHasSimilarArtists = viewModel.hasSimilarArtists
    }

    viewModel.getSimilarArtists()

    expect(expectedHasSimilarArtists).toEventually(beTrue())
  }

  func test_cellViewModelAtIndexPath_returnsCorrectValue() {
    let viewModel = SimilarsSectionTabViewModel(artist: sampleArtist,
                                                requestStrategy: requestStrategy,
                                                dependencies: dependencies)
    var expectedArtistNames: [String] = []
    viewModel.didUpdateData = {
      expectedArtistNames = (0..<viewModel.numberOfSimilarArtists).map {
        let cellViewModel = viewModel.cellViewModel(at: IndexPath(row: $0, section: 0))
        return cellViewModel.name
      }
    }

    viewModel.getSimilarArtists()

    expect(expectedArtistNames).toEventually(equal(["Artist1", "Artist4", "Artist3", "Artist2"]))
  }

  func test_selectingArtistAtIndexPath_returnsCorrectValue() {
    let viewModel = SimilarsSectionTabViewModel(artist: sampleArtist,
                                                requestStrategy: requestStrategy,
                                                dependencies: dependencies)
    let delegate = StubSimilarsSectionTabViewModelDelegate()
    viewModel.delegate = delegate

    viewModel.didUpdateData = {
      let indexPath = IndexPath(item: 1, section: 0)
      viewModel.selectArtist(at: indexPath)
    }

    viewModel.getSimilarArtists()

    expect(delegate.selectedArtist?.name).toEventually(equal("Artist4"))
  }

  func test_getSimilarArtists_setsIsLoadingToTrue() {
    requestStrategy.stubSimilarArtists = []
    let viewModel = SimilarsSectionTabViewModel(artist: sampleArtist,
                                                requestStrategy: requestStrategy,
                                                dependencies: dependencies)
    viewModel.getSimilarArtists()

    expect(viewModel.isLoading).to(beTrue())
  }

  func test_getSimilarArtists_setsIsLoadingToFalse_afterUpdatingData() {
    requestStrategy.stubSimilarArtists = []
    let viewModel = SimilarsSectionTabViewModel(artist: sampleArtist,
                                                requestStrategy: requestStrategy,
                                                dependencies: dependencies)
    var expectedIsLoading = true
    viewModel.didUpdateData = {
      expectedIsLoading = viewModel.isLoading
    }

    viewModel.getSimilarArtists()

    expect(expectedIsLoading).toEventually(beFalse())
  }

  func test_getSimilarArtists_callsDidReceiveError_whenErrorOccurs() {
    requestStrategy.stubSimilarArtists = []
    requestStrategy.getSimilarArtistsShouldReturnError = true
    let viewModel = SimilarsSectionTabViewModel(artist: sampleArtist,
                                                requestStrategy: requestStrategy,
                                                dependencies: dependencies)
    var didReceiveError = false
    viewModel.didReceiveError = { _ in
      didReceiveError = true
    }

    viewModel.getSimilarArtists()

    expect(didReceiveError).toEventually(beTrue())
  }
}
