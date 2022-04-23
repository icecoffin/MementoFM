//
//  SimilarsSectionTabViewModelTests.swift
//  MementoFMTests
//
//  Created by Daniel on 10/12/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble
import Combine

final class SimilarsSectionTabViewModelTests: XCTestCase {
    private final class Dependencies: ArtistSimilarsSectionViewModel.Dependencies {
        let artistService: ArtistServiceProtocol

        init(artistService: ArtistServiceProtocol) {
            self.artistService = artistService
        }
    }

    private final class TestSimilarsSectionTabViewModelDelegate: SimilarsSectionTabViewModelDelegate {
        var selectedArtist: Artist?
        func similarsSectionTabViewModel(_ viewModel: SimilarsSectionTabViewModel, didSelectArtist artist: Artist) {
            selectedArtist = artist
        }
    }

    private var artistService: MockArtistService!
    private var dependencies: Dependencies!
    private var requestStrategy: MockSimilarArtistsRequestStrategy!
    private var cancelBag = Set<AnyCancellable>()

    let sampleArtist: Artist = {
        let tags = [Tag(name: "Tag1", count: 1), Tag(name: "Tag2", count: 1), Tag(name: "Tag3", count: 1)]
        return Artist(name: "Artist",
                      playcount: 1,
                      urlString: "",
                      needsTagsUpdate: false,
                      tags: [],
                      topTags: tags,
                      country: nil)
    }()

    let similarArtists: [Artist] = {
        let tag1 = Tag(name: "Tag1", count: 1)
        let tag2 = Tag(name: "Tag2", count: 1)
        let tag3 = Tag(name: "Tag3", count: 1)

        return [Artist(name: "Artist1", playcount: 1, urlString: "", needsTagsUpdate: false, tags: [],
                       topTags: [tag1, tag2, tag3], country: nil),
                Artist(name: "Artist2", playcount: 2, urlString: "", needsTagsUpdate: false, tags: [],
                       topTags: [tag1, tag2], country: nil),
                Artist(name: "Artist3", playcount: 3, urlString: "", needsTagsUpdate: false, tags: [],
                       topTags: [tag1, tag2], country: nil),
                Artist(name: "Artist4", playcount: 4, urlString: "", needsTagsUpdate: false, tags: [],
                       topTags: [tag1, tag3], country: nil),
                Artist(name: "Artist5", playcount: 1, urlString: "", needsTagsUpdate: false, tags: [],
                       topTags: [tag1], country: nil)]
    }()

    override func setUp() {
        super.setUp()

        artistService = MockArtistService()
        requestStrategy = MockSimilarArtistsRequestStrategy()
        requestStrategy.customSimilarArtists = similarArtists
        requestStrategy.minNumberOfIntersectingTags = 2
        dependencies = Dependencies(artistService: artistService)
    }

    func test_getSimilarArtists_updatesNumberOfSimilarArtists() {
        let viewModel = SimilarsSectionTabViewModel(artist: sampleArtist,
                                                    canSelectSimilarArtists: true,
                                                    requestStrategy: requestStrategy,
                                                    dependencies: dependencies)
        var expectedNumberOfSimilarArtists = 0

        viewModel.didUpdate
            .sink(receiveValue: { _ in
                expectedNumberOfSimilarArtists = viewModel.numberOfSimilarArtists
            })
            .store(in: &cancelBag)

        viewModel.getSimilarArtists()

        expect(expectedNumberOfSimilarArtists) == 4
    }

    func test_getSimilarArtists_updatesHasSimilarArtists() {
        let viewModel = SimilarsSectionTabViewModel(artist: sampleArtist,
                                                    canSelectSimilarArtists: true,
                                                    requestStrategy: requestStrategy,
                                                    dependencies: dependencies)
        var expectedHasSimilarArtists = false
        viewModel.didUpdate
            .sink(receiveValue: { _ in
                expectedHasSimilarArtists = viewModel.hasSimilarArtists
            })
        .store(in: &cancelBag)

        viewModel.getSimilarArtists()

        expect(expectedHasSimilarArtists) == true
    }

    func test_cellViewModelAtIndexPath_returnsCorrectValue() {
        let viewModel = SimilarsSectionTabViewModel(artist: sampleArtist,
                                                    canSelectSimilarArtists: true,
                                                    requestStrategy: requestStrategy,
                                                    dependencies: dependencies)
        var expectedArtistNames: [String] = []
        viewModel.didUpdate
            .sink(receiveValue: { _ in
                expectedArtistNames = (0..<viewModel.numberOfSimilarArtists).map {
                    let cellViewModel = viewModel.cellViewModel(at: IndexPath(row: $0, section: 0))
                    return cellViewModel.name
                }
            })
            .store(in: &cancelBag)

        viewModel.getSimilarArtists()

        expect(expectedArtistNames) == ["Artist1", "Artist4", "Artist3", "Artist2"]
    }

    func test_selectingArtistAtIndexPath_returnsCorrectValue() {
        let viewModel = SimilarsSectionTabViewModel(artist: sampleArtist,
                                                    canSelectSimilarArtists: true,
                                                    requestStrategy: requestStrategy,
                                                    dependencies: dependencies)
        let delegate = TestSimilarsSectionTabViewModelDelegate()
        viewModel.delegate = delegate

        viewModel.didUpdate
            .sink(receiveValue: { _ in
                let indexPath = IndexPath(item: 1, section: 0)
                viewModel.selectArtist(at: indexPath)
            })
            .store(in: &cancelBag)

        viewModel.getSimilarArtists()

        expect(delegate.selectedArtist?.name) == "Artist4"
    }

    func test_getSimilarArtists_callsDidReceiveError_whenErrorOccurs() {
        requestStrategy.customSimilarArtists = []
        requestStrategy.getSimilarArtistsShouldReturnError = true
        let viewModel = SimilarsSectionTabViewModel(artist: sampleArtist,
                                                    canSelectSimilarArtists: true,
                                                    requestStrategy: requestStrategy,
                                                    dependencies: dependencies)
        var didReceiveError = false
        viewModel.didUpdate
            .sink(receiveValue: { result in
                switch result {
                case .success:
                    fail()
                case .failure:
                    didReceiveError = true
                }
            })
            .store(in: &cancelBag)

        viewModel.getSimilarArtists()

        expect(didReceiveError) == true
    }
}
