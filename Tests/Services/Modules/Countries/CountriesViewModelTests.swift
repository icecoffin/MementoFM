//
//  CountriesViewModelTests.swift
//  MementoFM
//
//  Created by Dani on 13.01.2020.
//  Copyright © 2020 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble

class CountriesViewModelTests: XCTestCase {
    class Dependencies: HasArtistService {
        let artistService: ArtistServiceProtocol

        init(artistService: ArtistServiceProtocol) {
            self.artistService = artistService
        }
    }

    class TestCountriesViewModelDelegate: CountriesViewModelDelegate {
        var selectedCountry: CountryType?
        func countriesViewModel(_ viewModel: CountriesViewModel, didSelectCountry country: CountryType) {
            selectedCountry = country
        }
    }

    var artistService: MockArtistService!
    var dependencies: Dependencies!
    var viewModel: CountriesViewModel!

    override func setUp() {
        super.setUp()

        artistService = MockArtistService()
        dependencies = Dependencies(artistService: artistService)
        viewModel = CountriesViewModel(dependencies: dependencies)
    }

    // MARK: - loadData

    func test_loadData_callsArtistService() {
        artistService.customCountriesWithCount = ["USA": 50, "Germany": 100]

        viewModel.loadData()

        expect(self.artistService.didCallGetCountriesWithCount) == true
    }

    func test_loadData_sortsCountriesByArtistCount() {
        artistService.customCountriesWithCount = ["USA": 50, "Germany": 100]

        viewModel.loadData()

        let indexPath = IndexPath(row: 0, section: 0)
        let cellViewModel = viewModel.cellViewModel(at: indexPath)
        expect(cellViewModel.country) == .named(name: "Germany")
    }

    // MARK: - numberOfCountries

    func test_numberOfCountries_returnsCorrectValue() {
        artistService.customCountriesWithCount = ["USA": 50, "Germany": 100]

        viewModel.loadData()

        expect(self.viewModel.numberOfCountries) == 2
    }

    // MARK: - selectCountry

    func test_selectCountry_notifiesDelegate() {
        artistService.customCountriesWithCount = ["USA": 50, "Germany": 100]

        let delegate = TestCountriesViewModelDelegate()
        viewModel.delegate = delegate

        viewModel.loadData()
        let indexPath = IndexPath(row: 0, section: 0)
        viewModel.selectCountry(at: indexPath)

        expect(delegate.selectedCountry) == .named(name: "Germany")
    }
}
