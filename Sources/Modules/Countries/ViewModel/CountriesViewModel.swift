//
//  CountriesViewModel.swift
//  MementoFM
//
//  Created by Dani on 21.12.2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import Foundation

protocol CountriesViewModelDelegate: class {
    func countriesViewModel(_ viewModel: CountriesViewModel, didSelectCountry country: CountryType)
}

final class CountriesViewModel {
    typealias Dependencies = HasCountryService

    private let dependencies: Dependencies
    private let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter
    }()

    private var cellViewModels: [CountryCellViewModel] = []

    weak var delegate: CountriesViewModelDelegate?

    var numberOfCountries: Int {
        return cellViewModels.count
    }

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

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
