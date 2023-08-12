//
//  LoadingViewTests.swift
//  MementoFMTests
//
//  Created by Dani on 18.12.2022.
//  Copyright © 2022 icecoffin. All rights reserved.
//

import XCTest
import SnapshotTesting
import InfrastructureTestingUtilities
@testable import MementoFM

final class LoadingViewTests: XCTestCase {
    func test_looksCorrect() {
        let view: LoadingView = makeAndSizeToFit(width: 375) { view in
            view.update(with: "Test message")
        }

        assertSnapshots(matching: view)
    }
}
