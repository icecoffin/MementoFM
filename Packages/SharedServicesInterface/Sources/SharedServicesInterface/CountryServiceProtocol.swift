import Foundation
import Combine

public protocol CountryServiceProtocol {
    func updateCountries() -> AnyPublisher<Void, Error>
    func getCountriesWithCounts() -> [String: Int]
}
