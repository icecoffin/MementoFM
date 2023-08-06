//
//  MockCountryService.swift
//  MementoFM
//
//  Created by Dani on 10.04.2020.
//  Copyright © 2020 icecoffin. All rights reserved.
//

import Foundation
import Combine
import SharedServicesInterface

public final class MockCountryService: CountryServiceProtocol {
    public init() { }

    public var didCallUpdateCountries = false
    public func updateCountries() -> AnyPublisher<Void, Error> {
        didCallUpdateCountries = true
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    public var customCountriesWithCount: [String: Int] = [:]
    public var didCallGetCountriesWithCount = false
    public func getCountriesWithCounts() -> [String: Int] {
        didCallGetCountriesWithCount = true
        return customCountriesWithCount
    }
}
