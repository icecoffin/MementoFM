//
//  LibraryArtistCellViewModelTests.swift
//  MementoFMTests
//
//  Created by Daniel on 04/12/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM

final class LibraryArtistCellViewModelTests: XCTestCase {
    private var sampleArtist: Artist {
        return Artist(
            id: "test_id",
            name: "Artist",
            playcount: 10,
            urlString: "",
            needsTagsUpdate: false,
            tags: [],
            topTags: [],
            country: nil
        )
    }

    func test_name_returnsArtistName() {
        let viewModel = LibraryArtistCellViewModel(artist: sampleArtist, index: 1, numberFormatter: NumberFormatter())
        XCTAssertEqual(viewModel.name, "Artist")
    }

    func test_playcount_returnsCorrectValue_basedOnArtistPlaycount() {
        let viewModel = LibraryArtistCellViewModel(artist: sampleArtist, index: 1, numberFormatter: NumberFormatter())
        XCTAssertEqual(viewModel.playcount, "10 plays")
    }

    func test_displayIndex_returnsCorrectValue() {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = Locale(identifier: "en_US")

        let viewModel = LibraryArtistCellViewModel(artist: sampleArtist, index: 1234, numberFormatter: numberFormatter)

        XCTAssertEqual(viewModel.displayIndex, "1,234")
    }
}
