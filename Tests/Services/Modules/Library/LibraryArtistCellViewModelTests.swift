//
//  LibraryArtistCellViewModelTests.swift
//  MementoFMTests
//
//  Created by Daniel on 04/12/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble

class LibraryArtistCellViewModelTests: XCTestCase {
  var sampleArtist: Artist {
    return Artist(name: "Artist",
                  playcount: 10,
                  urlString: "",
                  imageURLString: "https://example.com/1.jpg",
                  needsTagsUpdate: false,
                  tags: [],
                  topTags: [])
  }

  func test_name_returnsArtistName() {
    let viewModel = LibraryArtistCellViewModel(artist: sampleArtist)
    expect(viewModel.name).to(equal("Artist"))
  }

  func test_playcount_returnsCorrectValue_basedOnArtistPlaycount() {
    let viewModel = LibraryArtistCellViewModel(artist: sampleArtist)
    expect(viewModel.playcount).to(equal("10 plays"))
  }

  func test_imageURL_returnsCorrectURLFromArtist() {
    let viewModel = LibraryArtistCellViewModel(artist: sampleArtist)
    let url = URL(string: "https://example.com/1.jpg")
    expect(viewModel.imageURL).to(equal(url))
  }
}
