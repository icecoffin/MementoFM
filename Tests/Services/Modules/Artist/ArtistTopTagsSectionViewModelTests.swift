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
    private class TestArtistTopTagsSectionViewModelDelegate: ArtistTopTagsSectionViewModelDelegate {
        var selectedTagName: String = ""
        func artistTopTagsSectionViewModel(_ viewModel: ArtistTopTagsSectionViewModel, didSelectTagWithName name: String) {
            selectedTagName = name
        }
    }

    var sampleArtist: Artist = {
        let tags: [Tag] = [Tag(name: "Tag1", count: 1), Tag(name: "Tag2", count: 1)]
        return Artist(name: "Artist",
                      playcount: 1,
                      urlString: "",
                      needsTagsUpdate: false,
                      tags: tags,
                      topTags: tags,
                      country: nil)
    }()

    func func_numberOfTopTags_returnsCorrectValue() {
        let artist = sampleArtist
        let viewModel = ArtistTopTagsSectionViewModel(artist: artist)

        expect(viewModel.numberOfTopTags).to(equal(sampleArtist.topTags.count))
    }

    func test_hasTags_returnsTrue_whenArtistHasTags() {
        let artist = sampleArtist
        let viewModel1 = ArtistTopTagsSectionViewModel(artist: artist)

        expect(viewModel1.hasTags).to(beTrue())
    }

    func test_hasTags_returnsFalse_whenArtistHasNoTags() {
        let artistWithNoTags = Artist(name: "Artist",
                                      playcount: 1,
                                      urlString: "",
                                      needsTagsUpdate: false,
                                      tags: [],
                                      topTags: [],
                                      country: nil)
        let viewModel2 = ArtistTopTagsSectionViewModel(artist: artistWithNoTags)

        expect(viewModel2.hasTags).to(beFalse())
    }

    func test_cellViewModelAtIndexPath_returnsCorrectValue() {
        let artist = sampleArtist
        let viewModel = ArtistTopTagsSectionViewModel(artist: artist)
        let indexPath = IndexPath(row: 1, section: 0)

        let cellViewModel = viewModel.cellViewModel(at: indexPath)

        expect(cellViewModel.name).to(equal("Tag2"))
    }

    func test_selectTagWithName_notifiesDelegateCorrectly() {
        let artist = sampleArtist
        let viewModel = ArtistTopTagsSectionViewModel(artist: artist)
        let delegate = TestArtistTopTagsSectionViewModelDelegate()
        viewModel.delegate = delegate

        viewModel.selectTag(withName: "Tag2")

        expect(delegate.selectedTagName).to(equal("Tag2"))
    }
}
