//
//  ArtistsByTagViewModelTests.swift
//  MementoFMTests
//
//  Created by Daniel on 29/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble
import RealmSwift

class ArtistsByTagViewModelTests: XCTestCase {
    class Dependencies: ArtistsByTagViewModel.Dependencies {
        let artistService: ArtistServiceProtocol

        init(artistService: ArtistServiceProtocol) {
            self.artistService = artistService
        }
    }

    class TestArtistsByTagViewModelDelegate: ArtistListViewModelDelegate {
        var selectedArtist: Artist?
        func artistListViewModel(_ viewModel: ArtistListViewModel, didSelectArtist artist: Artist) {
            selectedArtist = artist
        }
    }

    var collection: MockPersistentMappedCollection<Artist>!
    var artistService: MockArtistService!
    var dependencies: Dependencies!
    var viewModel: ArtistsByTagViewModel!

    var sampleArtists: [Artist] = {
        let tag1 = Tag(name: "Tag1", count: 1)
        let tag2 = Tag(name: "Tag2", count: 2)

        return [
            Artist(name: "Artist1", playcount: 1, urlString: "", needsTagsUpdate: true, tags: [], topTags: [tag1], country: nil),
            Artist(name: "Artist2", playcount: 1, urlString: "", needsTagsUpdate: true, tags: [], topTags: [tag1], country: nil),
            Artist(name: "Artist3", playcount: 1, urlString: "", needsTagsUpdate: true, tags: [], topTags: [tag1], country: nil),
            Artist(name: "Artist4", playcount: 1, urlString: "", needsTagsUpdate: true, tags: [], topTags: [tag2], country: nil),
            Artist(name: "Artist5", playcount: 1, urlString: "", needsTagsUpdate: true, tags: [], topTags: [tag2], country: nil),
            Artist(name: "Artist6", playcount: 1, urlString: "", needsTagsUpdate: true, tags: [], topTags: [tag2], country: nil),
            Artist(name: "Artist7", playcount: 1, urlString: "", needsTagsUpdate: true, tags: [],
                   topTags: [tag1, tag2], country: nil)
        ]
    }()

    override func setUp() {
        artistService = MockArtistService()
        collection = MockPersistentMappedCollection<Artist>(values: sampleArtists)
        artistService.customMappedCollection = AnyPersistentMappedCollection(collection)
        dependencies = Dependencies(artistService: artistService)

        viewModel = ArtistsByTagViewModel(tagName: "Tag1", dependencies: dependencies)
    }

    override func tearDown() {
        artistService = nil
        dependencies = nil
    }

    // MARK: - itemCount

    func test_itemCount_returnsCorrectValue() {
        collection.customCount = 4

        expect(self.viewModel.itemCount) == 4
    }

    // MARK: - title

    func test_title_returnsCorrectValue() {
        expect(self.viewModel.title) == "Tag1"
    }

    // MARK: - artistViewModelAtIndexPath

    func test_artistViewModelAtIndexPath_returnsCorrectValue() {
        let indexPath = IndexPath(row: 1, section: 0)
        let artistViewModel = viewModel.artistViewModel(at: indexPath)

        expect(artistViewModel.name) == "Artist2"
    }

    // MARK: - selectArtistAtIndexPath

    func test_selectArtistAtIndexPath_notifiesDelegate() {
        let delegate = TestArtistsByTagViewModelDelegate()
        viewModel.delegate = delegate
        let indexPath = IndexPath(row: 1, section: 0)

        viewModel.selectArtist(at: indexPath)

        expect(delegate.selectedArtist) == sampleArtists[1]
    }

    // MARK: - performSearch

    func test_performSearch_setsCorrectPredicate() {
        viewModel.performSearch(withText: "test")

        let predicateFormat = artistService.customMappedCollection.predicate?.predicateFormat
        expect(predicateFormat) == "ANY topTags.name == \"Tag1\" AND name CONTAINS[cd] \"test\""
    }

    func test_performSearch_callsDidUpdateData() {
        var didUpdateData = false
        viewModel.didUpdateData = { _ in
            didUpdateData = true
        }

        viewModel.performSearch(withText: "test")

        expect(didUpdateData) == true
    }
}
