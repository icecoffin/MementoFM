//
//  CountryService.swift
//  MementoFM
//
//  Created by Dani on 10.04.2020.
//  Copyright © 2020 icecoffin. All rights reserved.
//

import Foundation
import Combine
import CombineSchedulers

// MARK: - CountryServiceProtocol

protocol CountryServiceProtocol {
    func updateCountries() -> AnyPublisher<Void, Error>
    func getCountriesWithCounts() -> [String: Int]
}

// MARK: - CountryService

final class CountryService: CountryServiceProtocol {
    // MARK: - Public properties

    private let artistStore: ArtistStore
    private let countryProvider: CountryProviding
    private let mainScheduler: AnySchedulerOf<DispatchQueue>
    private let backgroundScheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Init

    init(
        artistStore: ArtistStore,
        countryProvider: CountryProviding = CountryProvider(),
        mainScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler(),
        backgroundScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global().eraseToAnyScheduler()
    ) {
        self.artistStore = artistStore
        self.countryProvider = countryProvider
        self.mainScheduler = mainScheduler
        self.backgroundScheduler = backgroundScheduler
    }

    // MARK: - Public methods

    func updateCountries() -> AnyPublisher<Void, Error> {
        return Future<[Artist], Error> { promise in
            self.backgroundScheduler.schedule {
                let artists = self.artistStore.fetchAll()
                let updatedArtists: [Artist] = artists.map {
                    if let country = self.countryProvider.topCountry(for: $0) {
                        return $0.updatingCountry(to: country)
                    } else {
                        return $0
                    }
                }
                promise(.success(updatedArtists))
            }
        }
        .flatMap { artists in
            return self.artistStore.save(artists: artists)
        }
        .receive(on: mainScheduler)
        .eraseToAnyPublisher()
    }

    func getCountriesWithCounts() -> [String: Int] {
        let artists = artistStore.fetchAll()
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
