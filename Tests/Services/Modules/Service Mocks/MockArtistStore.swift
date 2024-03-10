import Foundation
import Combine
@testable import MementoFM

final class MockArtistStore: ArtistStore {
    private(set) var artistForNameCallCount = 0
    private(set) var artistForNameParameters: [String] = []
    func artist(for name: String) -> Artist? {
        artistForNameCallCount += 1
        artistForNameParameters.append(name)
        return nil
    }

    private(set) var fetchAllCallCount = 0
    private(set) var fetchAllParameters: NSPredicate?
    var customArtists: [Artist] = []
    func fetchAll(filteredBy predicate: NSPredicate?) -> [Artist] {
        fetchAllCallCount += 1
        fetchAllParameters = predicate
        return customArtists
    }

    private(set) var deleteAllCallCount = 0
    func deleteAll() -> AnyPublisher<Void, any Error> {
        deleteAllCallCount += 1
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    private(set) var saveCallCount = 0
    private(set) var saveParameters: [Artist]?
    func save(artists: [Artist]) -> AnyPublisher<Void, any Error> {
        saveCallCount += 1
        saveParameters = artists
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
