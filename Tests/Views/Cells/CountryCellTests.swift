//
//  CountryCellTests.swift
//  MementoFMTests
//
//  Created by Dani on 18.12.2022.
//  Copyright © 2022 icecoffin. All rights reserved.
//

import XCTest
import SnapshotTesting
import InfrastructureTestingUtilities
@testable import MementoFM

final class CountryCellTests: XCTestCase {
    func test_looksCorrect_forNamedCountry() {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let cellViewModel = CountryCellViewModel(name: "Test", count: 150, numberFormatter: numberFormatter)

        let cell: CountryCell = makeAndSizeToFit(width: 375) { cell in
            cell.backgroundColor = .systemBackground
            cell.configure(with: cellViewModel)
        }

        cell.frame.size.height = 48
        assertSnapshots(matching: cell)
    }

    func test_looksCorrect_forUnknownCountry() {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let cellViewModel = CountryCellViewModel(name: "", count: 150, numberFormatter: numberFormatter)

        let cell: CountryCell = makeAndSizeToFit(width: 375) { cell in
            cell.backgroundColor = .systemBackground
            cell.configure(with: cellViewModel)
        }

        cell.frame.size.height = 48
        assertSnapshots(matching: cell)
    }
}
