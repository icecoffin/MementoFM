//
//  LoadingFooterViewTests.swift
//  MementoFMTests
//
//  Created by Dani on 18.12.2022.
//  Copyright © 2022 icecoffin. All rights reserved.
//

import XCTest
import SnapshotTesting
import InfrastructureTestingUtilities
@testable import MementoFM

final class LoadingFooterViewTests: XCTestCase {
    func test_looksCorrect() {
        let view: LoadingFooterView = makeAndSizeToFit(width: 375) { _ in }
        assertSnapshots(matching: view)
    }
}
