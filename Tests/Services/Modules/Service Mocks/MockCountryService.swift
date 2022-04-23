//
//  MockCountryService.swift
//  MementoFM
//
//  Created by Dani on 10.04.2020.
//  Copyright © 2020 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import Combine

final class MockCountryService: CountryServiceProtocol {
    var didCallUpdateCountries = false
    func updateCountries() -> AnyPublisher<Void, Error> {
        didCallUpdateCountries = true
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    var customCountriesWithCount: [String: Int] = [:]
    var didCallGetCountriesWithCount = false
    func getCountriesWithCounts() -> [String: Int] {
        didCallGetCountriesWithCount = true
        return customCountriesWithCount
    }
}
