//
//  ArtistTopTagsSectionViewModelTests.swift
//  MementoFMTests
//
//  Created by Daniel on 07/12/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble

class ArtistTopTagsSectionViewModelTests: XCTestCase {
  // swiftlint:disable:next type_name
  private class StubArtistTopTagsSectionViewModelDelegate: ArtistTopTagsSectionViewModelDelegate {
    var selectedTagName: String = ""
    func artistTopTagsSectionViewModel(_ viewModel: ArtistTopTagsSectionViewModel, didSelectTagWithName name: String) {
      selectedTagName = name
    }
  }

  var sampleArtist: Artist = {
    let tags: [Tag] = [Tag(name: "Tag1", count: 1), Tag(name: "Tag2", count: 1)]
    return Artist(name: "Artist", playcount: 1, urlString: "", imageURLString: "", needsTagsUpdate: false, tags: tags, topTags: tags)
  }()

  func testGettingNumberOfTopTags() {
    let artist = sampleArtist
    let viewModel = ArtistTopTagsSectionViewModel(artist: artist)
    expect(viewModel.numberOfTopTags).to(equal(sampleArtist.topTags.count))
  }

  func testGettingHasTags() {
    let artist = sampleArtist
    let viewModel1 = ArtistTopTagsSectionViewModel(artist: artist)
    expect(viewModel1.hasTags).to(beTrue())

    let artistWithNoTags = Artist(name: "Artist", playcount: 1, urlString: "", imageURLString: "", needsTagsUpdate: false, tags: [], topTags: [])
    let viewModel2 = ArtistTopTagsSectionViewModel(artist: artistWithNoTags)
    expect(viewModel2.hasTags).to(beFalse())
  }

  func testGettingTagCellViewModel() {
    let artist = sampleArtist
    let viewModel = ArtistTopTagsSectionViewModel(artist: artist)
    let indexPath = IndexPath(row: 1, section: 0)
    let cellViewModel = viewModel.cellViewModel(at: indexPath)
    expect(cellViewModel.name).to(equal("Tag2"))
  }

  func testSelectingTag() {
    let artist = sampleArtist
    let viewModel = ArtistTopTagsSectionViewModel(artist: artist)
    let delegate = StubArtistTopTagsSectionViewModelDelegate()
    viewModel.delegate = delegate
    viewModel.selectTag(withName: "Tag2")
    expect(delegate.selectedTagName).to(equal("Tag2"))
  }
}
