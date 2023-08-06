//
//  ArtistCellTests.swift
//  MementoFMTests
//
//  Created by Dani on 18.12.2022.
//  Copyright © 2022 icecoffin. All rights reserved.
//

import XCTest
import SnapshotTesting
import InfrastructureTestingUtilities
@testable import MementoFM

final class ArtistCellTests: XCTestCase {
    func test_looksCorrect() {
        let artist = ModelFactory.generateArtist(playcount: 10)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let cellViewModel = LibraryArtistCellViewModel(artist: artist, index: 2, numberFormatter: numberFormatter)

        let cell: ArtistCell = makeAndSizeToFit(width: 375) { cell in
            cell.backgroundColor = .systemBackground
            cell.configure(with: cellViewModel)
        }

        assertSnapshots(matching: cell)
    }
}
