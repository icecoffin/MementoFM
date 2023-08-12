//
//  EmptyDataSetFooterViewTests.swift
//  MementoFMTests
//
//  Created by Dani on 18.12.2022.
//  Copyright © 2022 icecoffin. All rights reserved.
//

import XCTest
import SnapshotTesting
import InfrastructureTestingUtilities
@testable import MementoFM

final class EmptyDataSetFooterViewTests: XCTestCase {
    func test_looksCorrect() {
        let view: EmptyDataSetFooterView = makeAndSizeToFit(width: 375) { view in
            view.configure(with: "Test")
        }

        assertSnapshots(matching: view)
    }
}
