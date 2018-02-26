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

class ArtistSimilarsSectionViewModelTests: XCTestCase {
  class Dependencies: ArtistSimilarsSectionViewModel.Dependencies {
    let artistService: ArtistServiceProtocol

    init(artistService: ArtistServiceProtocol) {
      self.artistService = artistService
    }
  }

  // swiftlint:disable:next type_name
  class StubArtistSimilarsSectionViewModelDelegate: ArtistSimilarsSectionViewModelDelegate {
    var didCallDidSelectArtist = false
    func artistSimilarsSectionViewModel(_ viewModel: ArtistSimilarsSectionViewModel, didSelectArtist artist: Artist) {
      didCallDidSelectArtist = true
    }
  }

  let sampleArtist = ModelFactory.generateArtist()

  var artistService: StubArtistService!
  var dependencies: Dependencies!
  var tabViewModelFactory: StubArtistSimilarsSectionTabViewModelFactory!

  override func setUp() {
    super.setUp()
    artistService = StubArtistService()
    tabViewModelFactory = StubArtistSimilarsSectionTabViewModelFactory()
    dependencies = Dependencies(artistService: artistService)
  }

  func testCurrentTabViewModelAfterInit() {
    let artist = sampleArtist
    let viewModel = ArtistSimilarsSectionViewModel(artist: artist,
                                                   tabViewModelFactory: tabViewModelFactory,
                                                   dependencies: dependencies)
    expect(viewModel.currentTabViewModel).to(beIdenticalTo(tabViewModelFactory.firstTabViewModel))
  }

  func testGettingNumberOfSimilarArtists() {
    let artist = sampleArtist
    let viewModel = ArtistSimilarsSectionViewModel(artist: artist,
                                                   tabViewModelFactory: tabViewModelFactory,
                                                   dependencies: dependencies)
    tabViewModelFactory.firstTabViewModel.stubNumberOfSimilarArtists = 5
    expect(viewModel.numberOfSimilarArtists).to(equal(5))
  }

  func testGettingHasSimilarArtists() {
    let artist = sampleArtist
    let viewModel = ArtistSimilarsSectionViewModel(artist: artist,
                                                   tabViewModelFactory: tabViewModelFactory,
                                                   dependencies: dependencies)
    tabViewModelFactory.firstTabViewModel.stubHasSimilarArtists = true
    expect(viewModel.hasSimilarArtists).to(beTrue())
  }

  func testGettingIsLoading() {
    let artist = sampleArtist
    let viewModel = ArtistSimilarsSectionViewModel(artist: artist,
                                                   tabViewModelFactory: tabViewModelFactory,
                                                   dependencies: dependencies)
    tabViewModelFactory.firstTabViewModel.stubIsLoading = true
    expect(viewModel.isLoading).to(beTrue())
  }

  func testGettingEmptyDataSetText() {
    let artist = sampleArtist
    let viewModel = ArtistSimilarsSectionViewModel(artist: artist,
                                                   tabViewModelFactory: tabViewModelFactory,
                                                   dependencies: dependencies)
    tabViewModelFactory.firstTabViewModel.stubEmptyDataSetText = "Test"
    expect(viewModel.emptyDataSetText).to(equal("Test"))
  }

  func testGettingSimilarArtists() {
    let artist = sampleArtist
    let viewModel = ArtistSimilarsSectionViewModel(artist: artist,
                                                   tabViewModelFactory: tabViewModelFactory,
                                                   dependencies: dependencies)
    viewModel.getSimilarArtists()
    expect(self.tabViewModelFactory.firstTabViewModel.didCallGetSimilarArtists).to(beTrue())
  }

  func testGettingCellViewModel() {
    let artist = sampleArtist
    let viewModel = ArtistSimilarsSectionViewModel(artist: artist,
                                                   tabViewModelFactory: tabViewModelFactory,
                                                   dependencies: dependencies)
    let cellViewModel = SimilarArtistCellViewModel(artist: sampleArtist, commonTags: [])
    tabViewModelFactory.firstTabViewModel.stubCellViewModel = cellViewModel
    let indexPath = IndexPath(row: 0, section: 0)
    _ = viewModel.cellViewModel(at: indexPath)
    expect(self.tabViewModelFactory.firstTabViewModel.cellViewModelIndexPath).to(equal(indexPath))
  }

  func testSelectingArtist() {
    let artist = sampleArtist
    let viewModel = ArtistSimilarsSectionViewModel(artist: artist,
                                                   tabViewModelFactory: tabViewModelFactory,
                                                   dependencies: dependencies)
    let indexPath = IndexPath(row: 0, section: 0)
    viewModel.selectArtist(at: indexPath)
    expect(self.tabViewModelFactory.firstTabViewModel.selectedArtistIndexPath).to(equal(indexPath))
  }

  func testSelectingTab() {
    let artist = sampleArtist
    let viewModel = ArtistSimilarsSectionViewModel(artist: artist,
                                                   tabViewModelFactory: tabViewModelFactory,
                                                   dependencies: dependencies)
    viewModel.selectTab(at: 1)
    expect(viewModel.currentTabViewModel).to(beIdenticalTo(tabViewModelFactory.secondTabViewModel))
  }

  func testOnDidUpdateDataIsCalled() {
    let artist = sampleArtist
    let viewModel = ArtistSimilarsSectionViewModel(artist: artist,
                                                   tabViewModelFactory: tabViewModelFactory,
                                                   dependencies: dependencies)

    var didUpdateData = false
    viewModel.onDidUpdateData = {
      didUpdateData = true
    }

    tabViewModelFactory.firstTabViewModel.onDidUpdateData?()
    expect(didUpdateData).to(beTrue())
  }

  func testOnDidReceiveErrorIsCalled() {
    let artist = sampleArtist
    let viewModel = ArtistSimilarsSectionViewModel(artist: artist,
                                                   tabViewModelFactory: tabViewModelFactory,
                                                   dependencies: dependencies)

    var didReceiveError = false
    viewModel.onDidReceiveError = { _ in
      didReceiveError = true
    }

    let error = NSError(domain: "MementoFM", code: 6, userInfo: nil)
    tabViewModelFactory.firstTabViewModel.onDidReceiveError?(error)
    expect(didReceiveError).to(beTrue())
  }

  func testSelectArtistDelegateMethodIsCalled() {
    let artist = sampleArtist
    let viewModel = ArtistSimilarsSectionViewModel(artist: artist,
                                                   tabViewModelFactory: tabViewModelFactory,
                                                   dependencies: dependencies)
    let delegate = StubArtistSimilarsSectionViewModelDelegate()
    viewModel.delegate = delegate

    let requestStrategy = SimilarArtistsLocalRequestStrategy(dependencies: dependencies)
    let tabViewModel = SimilarsSectionTabViewModel(artist: artist,
                                                   requestStrategy: requestStrategy,
                                                   dependencies: dependencies)
    viewModel.similarsSectionTabViewModel(tabViewModel, didSelectArtist: artist)
    expect(delegate.didCallDidSelectArtist).to(beTrue())
  }
}
