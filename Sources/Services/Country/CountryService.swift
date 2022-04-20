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

    private let persistentStore: PersistentStore
    private let countryProvider: CountryProviding
    private let dispatcher: Dispatcher
    private let mainScheduler: AnySchedulerOf<DispatchQueue>
    private let backgroundScheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Init

    init(persistentStore: PersistentStore,
         countryProvider: CountryProviding = CountryProvider(),
         dispatcher: Dispatcher = AsyncDispatcher.global,
         mainScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler(),
         backgroundScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global().eraseToAnyScheduler()) {
        self.persistentStore = persistentStore
        self.countryProvider = countryProvider
        self.dispatcher = dispatcher
        self.mainScheduler = mainScheduler
        self.backgroundScheduler = backgroundScheduler
    }

    // MARK: - Public methods

    func updateCountries() -> AnyPublisher<Void, Error> {
        return Future<[Artist], Error>() { promise in
            self.backgroundScheduler.schedule {
                let artists = self.persistentStore.objects(Artist.self)
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
            return self.persistentStore.save(artists)
        }
        .receive(on: mainScheduler)
        .eraseToAnyPublisher()
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
