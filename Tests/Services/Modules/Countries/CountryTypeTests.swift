//
//  CountryTypeTests.swift
//  MementoFMTests
//
//  Created by Dani on 13.01.2020.
//  Copyright © 2020 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM

final class CountryTypeTests: XCTestCase {
    func test_displayName_returnsCorrectValue_forUnknownCountry() {
        let country = CountryType.unknown

        XCTAssertEqual(country.displayName, "unknown")
    }

    func test_displayName_returnsCorrectValue_forNamedCountry() {
        let country = CountryType.named(name: "Germany")

        XCTAssertEqual(country.displayName, "Germany")
    }
}
