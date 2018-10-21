//
//  ArtistInfoSectionViewModelTests.swift
//  MementoFMTests
//

import XCTest
@testable import MementoFM
import Nimble

class ArtistInfoSectionViewModelTests: XCTestCase {
  var sampleArtist = ModelFactory.generateArtist()

  func test_numberOfItems_returnsCorrectValue() {
    let viewModel = ArtistInfoSectionViewModel(artist: sampleArtist)
    expect(viewModel.numberOfItems).to(equal(1))
  }

  func test_itemViewModelAtIndex_returnsCorrectValue() {
    let viewModel = ArtistInfoSectionViewModel(artist: sampleArtist)
    let itemViewModel = viewModel.itemViewModel(at: 0)
    let expectedImageURL = URL(string: "http://example.com/artist1.jpg")
    expect(itemViewModel.imageURL).to(equal(expectedImageURL))
  }
}
