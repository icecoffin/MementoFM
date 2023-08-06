//
//  TagCellTests.swift
//  MementoFMTests
//
//  Created by Dani on 18.12.2022.
//  Copyright © 2022 icecoffin. All rights reserved.
//

import XCTest
import SnapshotTesting
@testable import MementoFM
import InfrastructureTestingUtilities

final class TagCellTests: XCTestCase {
    func test_looksCorrect_whenShowsCount() {
        let tag = ModelFactory.generateTag(index: 5, for: "")
        let cellViewModel = TagCellViewModel(tag: tag, showCount: true)

        let cell: TagCell = makeAndSizeToFit { cell in
            cell.backgroundColor = .systemBackground
            cell.configure(with: cellViewModel)
        }

        assertSnapshots(matching: cell)
    }

    func test_looksCorrect_whenDoesNotShowCount() {
        let tag = ModelFactory.generateTag(index: 8, for: "")
        let cellViewModel = TagCellViewModel(tag: tag, showCount: false)

        let cell: TagCell = makeAndSizeToFit { cell in
            cell.backgroundColor = .systemBackground
            cell.configure(with: cellViewModel)
        }

        assertSnapshots(matching: cell)
    }
}
