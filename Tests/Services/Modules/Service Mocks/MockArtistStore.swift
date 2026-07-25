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
    func deleteAll() async throws {
        deleteAllCallCount += 1
    }

    private(set) var saveCallCount = 0
    private(set) var saveParameters: [Artist]?
    func save(artists: [Artist]) async throws {
        saveCallCount += 1
        saveParameters = artists
    }

    var customMappedCollection: AnyPersistentMappedCollection<Artist>?
    private(set) var mappedCollectionParameters: (predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor])?
    func mappedCollection(
        filteredUsing predicate: NSPredicate?,
        sortedBy sortDescriptors: [NSSortDescriptor]
    ) -> AnyPersistentMappedCollection<Artist> {
        mappedCollectionParameters = (predicate, sortDescriptors)
        return customMappedCollection ?? AnyPersistentMappedCollection(MockPersistentMappedCollection<Artist>(values: []))
    }
}
