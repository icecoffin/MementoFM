import Foundation
import Combine
@testable import MementoFM

final class MockArtistStore: ArtistStore {
    private(set) var artistForIDCallCount = 0
    private(set) var artistForIDParameters: [String] = []
    func artist(for id: String) -> Artist? {
        artistForIDCallCount += 1
        artistForIDParameters.append(id)
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

    var customMappedCollection: AnyPersistentMappedCollection<Artist>?
    private(set) var mappedCollectionParameters: (predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor])?
    func mappedCollection(filteredUsing predicate: NSPredicate?, sortedBy sortDescriptors: [NSSortDescriptor]) -> AnyPersistentMappedCollection<Artist> {
        mappedCollectionParameters = (predicate, sortDescriptors)
        return customMappedCollection ?? AnyPersistentMappedCollection(MockPersistentMappedCollection<Artist>(values: []))
    }
}
