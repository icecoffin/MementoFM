//
//  MockCountryService.swift
//  MementoFM
//
//  Created by Dani on 10.04.2020.
//  Copyright © 2020 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import PromiseKit

class MockCountryService: CountryServiceProtocol {
    var didCallUpdateCountries = false
    func updateCountries() -> Promise<Void> {
        didCallUpdateCountries = true
        return .value(())
    }

    var customCountriesWithCount: [String: Int] = [:]
    var didCallGetCountriesWithCount = false
    func getCountriesWithCounts() -> [String: Int] {
        didCallGetCountriesWithCount = true
        return customCountriesWithCount
    }
}
