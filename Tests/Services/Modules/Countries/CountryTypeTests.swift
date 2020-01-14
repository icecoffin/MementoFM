//
//  CountryTypeTests.swift
//  MementoFMTests
//
//  Created by Dani on 13.01.2020.
//  Copyright © 2020 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble

class CountryTypeTests: XCTestCase {
  func test_displayName_returnsCorrectValue_forUnknownCountry() {
    let country = CountryType.unknown

    expect(country.displayName) == "unknown"
  }

  func test_displayName_returnsCorrectValue_forNamedCountry() {
    let country = CountryType.named(name: "Germany")

    expect(country.displayName) == "Germany"
  }
}
