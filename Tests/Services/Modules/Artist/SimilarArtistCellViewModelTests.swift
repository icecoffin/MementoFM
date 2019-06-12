//
//  SimilarArtistCellViewModelTests.swift
//  MementoFMTests
//
//  Created by Daniel on 10/12/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble

class SimilarArtistCellViewModelTests: XCTestCase {
  var sampleArtist: Artist = {
    let tags = [Tag(name: "Tag1", count: 1),
                Tag(name: "Tag2", count: 1),
                Tag(name: "Tag3", count: 1),
                Tag(name: "Tag4", count: 1),
                Tag(name: "Tag5", count: 1)]
    return Artist(name: "Artist",
                  playcount: 10,
                  urlString: "",
                  needsTagsUpdate: false,
                  tags: [],
                  topTags: tags)
  }()

  let commonTags = ["Tag1", "Tag3"]

  func test_name_returnsArtistName() {
    let viewModel = SimilarArtistCellViewModel(artist: sampleArtist, commonTags: commonTags, index: 1)
    expect(viewModel.name).to(equal("Artist"))
  }

  func test_playcount_returnsCorrectValue_basedOnArtistPlaycount() {
    let viewModel = SimilarArtistCellViewModel(artist: sampleArtist, commonTags: commonTags, index: 1)
    expect(viewModel.playcount).to(equal("10 plays"))
  }

  func test_index_returnsCorrectValue() {
    let viewModel = SimilarArtistCellViewModel(artist: sampleArtist, commonTags: commonTags, index: 1)
    expect(viewModel.displayIndex).to(equal("1"))
  }

  func test_tags_returnsCorrectlyAttributedTags_basedOnCommonTags() {
    let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldContentSecondary]
    var expectedTagsArray: [NSAttributedString] = []
    expectedTagsArray.append(NSAttributedString(string: "Tag1", attributes: attributes))
    expectedTagsArray.append(NSAttributedString(string: "Tag2"))
    expectedTagsArray.append(NSAttributedString(string: "Tag3", attributes: attributes))
    expectedTagsArray.append(NSAttributedString(string: "Tag4"))
    expectedTagsArray.append(NSAttributedString(string: "Tag5"))
    let expectedTags = expectedTagsArray.joined(separator: ", ")

    let viewModel = SimilarArtistCellViewModel(artist: sampleArtist, commonTags: commonTags, index: 1)
    expect(viewModel.tags).to(equal(expectedTags))
  }
}
