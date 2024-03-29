//
//  CountriesViewModel.swift
//  MementoFM
//
//  Created by Dani on 21.12.2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import Foundation

// MARK: - CountriesViewModelDelegate

protocol CountriesViewModelDelegate: AnyObject {
    func countriesViewModel(_ viewModel: CountriesViewModel, didSelectCountry country: CountryType)
}

final class CountriesViewModel {
    typealias Dependencies = HasCountryService

    // MARK: - Private properties

    private let dependencies: Dependencies
    private let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter
    }()

    private var cellViewModels: [CountryCellViewModel] = []

    // MARK: - Public properties

    weak var delegate: CountriesViewModelDelegate?

    var numberOfCountries: Int {
        return cellViewModels.count
    }

    // MARK: - Init

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    // MARK: - Public methods

    func loadData() {
        let result = dependencies.countryService.getCountriesWithCounts()
        cellViewModels = result
            .sorted { $0.value > $1.value }
            .map { key, value in
                return CountryCellViewModel(name: key, count: value, numberFormatter: numberFormatter)
        }
    }

    func cellViewModel(at indexPath: IndexPath) -> CountryCellViewModel {
        return cellViewModels[indexPath.row]
    }

    func selectCountry(at indexPath: IndexPath) {
        let country = cellViewModels[indexPath.row].country
        delegate?.countriesViewModel(self, didSelectCountry: country)
    }
}
