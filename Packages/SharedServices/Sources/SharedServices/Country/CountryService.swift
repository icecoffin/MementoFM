import Foundation
import Combine
import CombineSchedulers
import SharedServicesInterface
import PersistenceInterface
import TransientModels

public final class CountryService: CountryServiceProtocol {
    // MARK: - Public properties

    private let persistentStore: PersistentStore
    private let countryProvider: CountryProviding
    private let mainScheduler: AnySchedulerOf<DispatchQueue>
    private let backgroundScheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Init

    public convenience init(persistentStore: PersistentStore) {
        self.init(
            persistentStore: persistentStore,
            countryProvider: CountryProvider(),
            mainScheduler: DispatchQueue.main.eraseToAnyScheduler(),
            backgroundScheduler: DispatchQueue.global().eraseToAnyScheduler()
        )
    }

    init(
        persistentStore: PersistentStore,
        countryProvider: CountryProviding,
        mainScheduler: AnySchedulerOf<DispatchQueue>,
        backgroundScheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.persistentStore = persistentStore
        self.countryProvider = countryProvider
        self.mainScheduler = mainScheduler
        self.backgroundScheduler = backgroundScheduler
    }

    // MARK: - Public methods

    public func updateCountries() -> AnyPublisher<Void, Error> {
        return Future<[Artist], Error> { promise in
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

    public func getCountriesWithCounts() -> [String: Int] {
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
