//
//  ArtistTagsCellTests.swift
//  MementoFMTests
//
//  Created by Dani on 18.12.2022.
//  Copyright © 2022 icecoffin. All rights reserved.
//

import XCTest
import SnapshotTesting
@testable import MementoFM
import InfrastructureTestingUtilities

final class ArtistTagsCellTests: XCTestCase {
    func test_looksCorrect_whenTagsAreOnOneLine() {
        let dataSource = MockArtistTagsCellDataSource()
        dataSource.numberOfTopTags = 3
        let cell: ArtistTagsCell = makeAndSizeToFit(width: 375) { cell in
            cell.dataSource = dataSource
        }

        assertSnapshots(matching: cell)
    }

    func test_looksCorrect_whenTagsAreOnMultipleLines() {
        let dataSource = MockArtistTagsCellDataSource()
        dataSource.numberOfTopTags = 10
        let cell: ArtistTagsCell = makeAndSizeToFit(width: 375) { cell in
            cell.dataSource = dataSource
        }

        assertSnapshots(matching: cell)
    }
}

private final class MockArtistTagsCellDataSource: ArtistTagsCellDataSource {
    var numberOfTopTags = 0

    func numberOfTopTags(in cell: ArtistTagsCell) -> Int {
        return numberOfTopTags
    }

    func tagCellViewModel(at indexPath: IndexPath, in cell: ArtistTagsCell) -> TagCellViewModel {
        let tag = ModelFactory.generateTag(index: indexPath.row + 1, for: "Artist")
        return TagCellViewModel(tag: tag, showCount: false)
    }
}
