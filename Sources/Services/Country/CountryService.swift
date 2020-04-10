//
//  CountryService.swift
//  MementoFM
//
//  Created by Dani on 10.04.2020.
//  Copyright © 2020 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

protocol CountryServiceProtocol {
    func updateCountries() -> Promise<Void>
    func getCountriesWithCounts() -> [String: Int]
}

final class CountryService: CountryServiceProtocol {
    private let persistentStore: PersistentStore
    private let countryProvider: CountryProviding
    private let dispatcher: Dispatcher

    init(persistentStore: PersistentStore,
         countryProvider: CountryProviding = CountryProvider(),
         dispatcher: Dispatcher = AsyncDispatcher.global) {
        self.persistentStore = persistentStore
        self.countryProvider = countryProvider
        self.dispatcher = dispatcher
    }

    func updateCountries() -> Promise<Void> {
        return dispatcher.dispatch { () -> [Artist] in
            let artists = self.persistentStore.objects(Artist.self)
            return artists.map {
                if let country = self.countryProvider.topCountry(for: $0) {
                    return $0.updatingCountry(to: country)
                } else {
                    return $0
                }
            }
        }.then { artists in
            return self.persistentStore.save(artists)
        }
    }

    func getCountriesWithCounts() -> [String: Int] {
        let artists = persistentStore.objects(Artist.self)
        return artists.reduce([:]) { result, artist in
            var mutableResult = result
            let country = artist.country ?? ""
            if let value = mutableResult[country] {
                mutableResult[country] = value + 1
            } else {
                mutableResult[country] = 1
            }
            return mutableResult
        }
    }
}
