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
                      needsTagsUpdate: false,
                      tags: [],
                      topTags: [],
                      country: nil)
    }

    func test_name_returnsArtistName() {
        let viewModel = LibraryArtistCellViewModel(artist: sampleArtist, index: 1, numberFormatter: NumberFormatter())
        expect(viewModel.name) == "Artist"
    }

    func test_playcount_returnsCorrectValue_basedOnArtistPlaycount() {
        let viewModel = LibraryArtistCellViewModel(artist: sampleArtist, index: 1, numberFormatter: NumberFormatter())
        expect(viewModel.playcount) == "10 plays"
    }

    func test_displayIndex_returnsCorrectValue() {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal

        let viewModel = LibraryArtistCellViewModel(artist: sampleArtist, index: 1234, numberFormatter: numberFormatter)

        expect(viewModel.displayIndex) == "1,234"
    }
}
