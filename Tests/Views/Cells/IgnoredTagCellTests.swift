//
//  IgnoredTagCellTests.swift
//  MementoFMTests
//
//  Created by Dani on 18.12.2022.
//  Copyright © 2022 icecoffin. All rights reserved.
//

import XCTest
import SnapshotTesting
@testable import MementoFM

final class IgnoredTagCellTests: XCTestCase {
    func test_looksCorrect() {
        let tag = ModelFactory.generateIgnoredTag()
        let cellViewModel = IgnoredTagCellViewModel(tag: tag)
        let cell: IgnoredTagCell = makeAndSizeToFit(width: 375) { cell in
            cell.backgroundColor = .systemBackground
            cell.configure(with: cellViewModel)
        }

        assertSnapshots(matching: cell)
    }
}
