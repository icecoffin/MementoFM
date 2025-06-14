//
//  ArtistTopTagsSectionViewModelTests.swift
//  MementoFMTests
//
//  Created by Daniel on 07/12/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM

final class ArtistTopTagsSectionViewModelTests: XCTestCase {
    // swiftlint:disable:next type_name
    private final class TestArtistTopTagsSectionViewModelDelegate: ArtistTopTagsSectionViewModelDelegate {
        var selectedTagName: String = ""
        func artistTopTagsSectionViewModel(_ viewModel: ArtistTopTagsSectionViewModel, didSelectTagWithName name: String) {
            selectedTagName = name
        }
    }

    private var sampleArtist: Artist = {
        let tags: [Tag] = [Tag(name: "Tag1", count: 1), Tag(name: "Tag2", count: 1)]
        return Artist(
            id: "test_id",
            name: "Artist",
            playcount: 1,
            urlString: "",
            needsTagsUpdate: false,
            tags: tags,
            topTags: tags,
            country: nil
        )
    }()

    func test_numberOfTopTags_returnsCorrectValue() {
        let artist = sampleArtist
        let viewModel = ArtistTopTagsSectionViewModel(artist: artist)

        XCTAssertEqual(viewModel.numberOfTopTags, sampleArtist.topTags.count)
    }

    func test_hasTags_returnsTrue_whenArtistHasTags() {
        let artist = sampleArtist
        let viewModel1 = ArtistTopTagsSectionViewModel(artist: artist)

        XCTAssertTrue(viewModel1.hasTags)
    }

    func test_hasTags_returnsFalse_whenArtistHasNoTags() {
        let artistWithNoTags = Artist(
            id: "test_id",
            name: "Artist",
            playcount: 1,
            urlString: "",
            needsTagsUpdate: false,
            tags: [],
            topTags: [],
            country: nil
        )
        let viewModel2 = ArtistTopTagsSectionViewModel(artist: artistWithNoTags)

        XCTAssertFalse(viewModel2.hasTags)
    }

    func test_cellViewModelAtIndexPath_returnsCorrectValue() {
        let artist = sampleArtist
        let viewModel = ArtistTopTagsSectionViewModel(artist: artist)
        let indexPath = IndexPath(row: 1, section: 0)

        let cellViewModel = viewModel.cellViewModel(at: indexPath)

        XCTAssertEqual(cellViewModel.name, "Tag2")
    }

    func test_selectTagWithName_notifiesDelegateCorrectly() {
        let artist = sampleArtist
        let viewModel = ArtistTopTagsSectionViewModel(artist: artist)
        let delegate = TestArtistTopTagsSectionViewModelDelegate()
        viewModel.delegate = delegate

        viewModel.selectTag(withName: "Tag2")

        XCTAssertEqual(delegate.selectedTagName, "Tag2")
    }
}
