//
//  CountriesViewModelTests.swift
//  MementoFM
//
//  Created by Dani on 13.01.2020.
//  Copyright © 2020 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM

final class CountriesViewModelTests: XCTestCase {
    private final class Dependencies: HasCountryService {
        let countryService: CountryServiceProtocol

        init(countryService: CountryServiceProtocol) {
            self.countryService = countryService
        }
    }

    private final class TestCountriesViewModelDelegate: CountriesViewModelDelegate {
        var selectedCountry: CountryType?
        func countriesViewModel(_ viewModel: CountriesViewModel, didSelectCountry country: CountryType) {
            selectedCountry = country
        }
    }

    private var countryService: MockCountryService!
    private var dependencies: Dependencies!
    private var viewModel: CountriesViewModel!

    override func setUp() {
        super.setUp()

        countryService = MockCountryService()
        dependencies = Dependencies(countryService: countryService)
        viewModel = CountriesViewModel(dependencies: dependencies)
    }

    override func tearDown() {
        countryService = nil
        dependencies = nil
        viewModel = nil

        super.tearDown()
    }

    // MARK: - loadData

    func test_loadData_callsArtistService() {
        countryService.customCountriesWithCount = ["USA": 50, "Germany": 100]

        viewModel.loadData()

        XCTAssertTrue(countryService.didCallGetCountriesWithCount)
    }

    func test_loadData_sortsCountriesByArtistCount() {
        countryService.customCountriesWithCount = ["USA": 50, "Germany": 100]

        viewModel.loadData()

        let indexPath = IndexPath(row: 0, section: 0)
        let cellViewModel = viewModel.cellViewModel(at: indexPath)
        XCTAssertEqual(cellViewModel.country, .named(name: "Germany"))
    }

    // MARK: - numberOfCountries

    func test_numberOfCountries_returnsCorrectValue() {
        countryService.customCountriesWithCount = ["USA": 50, "Germany": 100]

        viewModel.loadData()

        XCTAssertEqual(viewModel.numberOfCountries, 2)
    }

    // MARK: - selectCountry

    func test_selectCountry_notifiesDelegate() {
        countryService.customCountriesWithCount = ["USA": 50, "Germany": 100]

        let delegate = TestCountriesViewModelDelegate()
        viewModel.delegate = delegate

        viewModel.loadData()
        let indexPath = IndexPath(row: 0, section: 0)
        viewModel.selectCountry(at: indexPath)

        XCTAssertEqual(delegate.selectedCountry, .named(name: "Germany"))
    }
}
