//
//  ArtistsByTagViewModelTests.swift
//  MementoFMTests
//
//  Created by Daniel on 29/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM

import RealmSwift
import Combine

final class ArtistsByTagViewModelTests: XCTestCase {
    private final class Dependencies: ArtistsByTagViewModel.Dependencies {
        let artistService: ArtistServiceProtocol

        init(artistService: ArtistServiceProtocol) {
            self.artistService = artistService
        }
    }

    private final class TestArtistsByTagViewModelDelegate: ArtistListViewModelDelegate {
        var selectedArtist: Artist?
        func artistListViewModel(_ viewModel: ArtistListViewModel, didSelectArtist artist: Artist) {
            selectedArtist = artist
        }
    }

    private var collection: MockPersistentMappedCollection<Artist>!
    private var artistService: MockArtistService!
    private var dependencies: Dependencies!
    private var viewModel: ArtistsByTagViewModel!
    private var cancelBag: Set<AnyCancellable>!

    private var sampleArtists: [Artist] = {
        let tag1 = Tag(name: "Tag1", count: 1)
        let tag2 = Tag(name: "Tag2", count: 2)

        return [
            Artist(id: "test_id_1", name: "Artist1", playcount: 1, urlString: "", needsTagsUpdate: true, tags: [], topTags: [tag1], country: nil),
            Artist(id: "test_id_2", name: "Artist2", playcount: 1, urlString: "", needsTagsUpdate: true, tags: [], topTags: [tag1], country: nil),
            Artist(id: "test_id_3", name: "Artist3", playcount: 1, urlString: "", needsTagsUpdate: true, tags: [], topTags: [tag1], country: nil),
            Artist(id: "test_id_4", name: "Artist4", playcount: 1, urlString: "", needsTagsUpdate: true, tags: [], topTags: [tag2], country: nil),
            Artist(id: "test_id_5", name: "Artist5", playcount: 1, urlString: "", needsTagsUpdate: true, tags: [], topTags: [tag2], country: nil),
            Artist(id: "test_id_6", name: "Artist6", playcount: 1, urlString: "", needsTagsUpdate: true, tags: [], topTags: [tag2], country: nil),
            Artist(id: "test_id_7", name: "Artist7", playcount: 1, urlString: "", needsTagsUpdate: true, tags: [], topTags: [tag1, tag2], country: nil)
        ]
    }()

    override func setUp() {
        artistService = MockArtistService()
        collection = MockPersistentMappedCollection<Artist>(values: sampleArtists)
        artistService.customMappedCollection = AnyPersistentMappedCollection(collection)
        dependencies = Dependencies(artistService: artistService)
        cancelBag = .init()

        viewModel = ArtistsByTagViewModel(tagName: "Tag1", dependencies: dependencies)
    }

    override func tearDown() {
        artistService = nil
        collection = nil
        dependencies = nil
        cancelBag = nil
        viewModel = nil

        super.tearDown()
    }

    // MARK: - itemCount

    func test_itemCount_returnsCorrectValue() {
        collection.customCount = 4

        XCTAssertEqual(viewModel.itemCount, 4)
    }

    // MARK: - title

    func test_title_returnsCorrectValue() {
        XCTAssertEqual(viewModel.title, "Tag1")
    }

    // MARK: - artistViewModelAtIndexPath

    func test_artistViewModelAtIndexPath_returnsCorrectValue() {
        let indexPath = IndexPath(row: 1, section: 0)
        let artistViewModel = viewModel.artistViewModel(at: indexPath)

        XCTAssertEqual(artistViewModel.name, "Artist2")
    }

    // MARK: - selectArtistAtIndexPath

    func test_selectArtistAtIndexPath_notifiesDelegate() {
        let delegate = TestArtistsByTagViewModelDelegate()
        viewModel.delegate = delegate
        let indexPath = IndexPath(row: 1, section: 0)

        viewModel.selectArtist(at: indexPath)

        XCTAssertEqual(delegate.selectedArtist, sampleArtists[1])
    }

    // MARK: - performSearch

    func test_performSearch_setsCorrectPredicate() {
        viewModel.performSearch(withText: "test")

        let predicateFormat = artistService.customMappedCollection.predicate?.predicateFormat
        XCTAssertEqual(predicateFormat, "ANY topTags.name == \"Tag1\" AND name CONTAINS[cd] \"test\"")
    }

    func test_performSearch_emitsDidUpdate() {
        var didUpdateData = false
        viewModel.didUpdate
            .sink(receiveValue: { _ in
                didUpdateData = true
            })
            .store(in: &cancelBag)

        viewModel.performSearch(withText: "test")

        XCTAssertTrue(didUpdateData)
    }
}
