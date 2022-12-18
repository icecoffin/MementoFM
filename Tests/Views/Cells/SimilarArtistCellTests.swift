//
//  SimilarArtistCellTests.swift
//  MementoFMTests
//
//  Created by Dani on 18.12.2022.
//  Copyright © 2022 icecoffin. All rights reserved.
//

import XCTest
import SnapshotTesting
@testable import MementoFM

final class SimilarArtistCellTests: XCTestCase {
    func test_looksCorrect() {
        let tags = ModelFactory.generateTags(inAmount: 5, for: "")
        let artist = ModelFactory.generateArtist(playcount: 10, topTags: tags)
        let cellViewModel = SimilarArtistCellViewModel(
            artist: artist,
            commonTags: [tags[0].name, tags[2].name],
            index: 2
        )

        let cell: SimilarArtistCell = makeAndSizeToFit(width: 375) { cell in
            cell.backgroundColor = .systemBackground
            cell.configure(with: cellViewModel)
        }

        assertSnapshots(matching: cell)
    }
}
