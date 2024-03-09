//
//  CountryCellViewModelTests.swift
//  MementoFM
//
//  Created by Dani on 24.02.2020.
//  Copyright © 2020 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble

final class CountryCellViewModelTests: XCTestCase {
    // MARK: - country

    func test_country_returnsCorrectCountryForEmptyName() {
        let viewModel = CountryCellViewModel(name: "", count: 1, numberFormatter: NumberFormatter())

        expect(viewModel.country) == .unknown
    }

    func test_country_returnsCorrectCountryForNotEmptyName() {
        let viewModel = CountryCellViewModel(name: "Test", count: 1, numberFormatter: NumberFormatter())

        expect(viewModel.country) == .named(name: "Test")
    }

    // MARK: - countText

    func test_countText_isCorrectInSingular() {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let viewModel = CountryCellViewModel(name: "Test", count: 1, numberFormatter: numberFormatter)

        expect(viewModel.countText) == "1 artist"
    }

    func test_countText_isCorrectInPlural() {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = Locale(identifier: "en_US")
        let viewModel = CountryCellViewModel(name: "Test", count: 1234, numberFormatter: numberFormatter)

        expect(viewModel.countText) == "1,234 artists"
    }
}
