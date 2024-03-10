import Foundation
import Combine

// MARK: - ArtistStore

protocol ArtistStore {
    func artist(for name: String) -> Artist?
    func deleteAll() -> AnyPublisher<Void, Error>
    func fetchAll(filteredBy predicate: NSPredicate?) -> [Artist]
    func save(artists: [Artist]) -> AnyPublisher<Void, Error>
}

extension ArtistStore {
    func fetchAll() -> [Artist] {
        return fetchAll(filteredBy: nil)
    }
}

// MARK: - PersistentArtistStore

final class PersistentArtistStore: ArtistStore {
    private let persistentStore: PersistentStore

    init(persistentStore: PersistentStore) {
        self.persistentStore = persistentStore
    }

    func artist(for name: String) -> Artist? {
        return persistentStore.object(ofType: Artist.self, forPrimaryKey: name)
    }

    func deleteAll() -> AnyPublisher<Void, Error> {
        persistentStore.deleteObjects(ofType: Artist.self)
    }

    func fetchAll(filteredBy predicate: NSPredicate?) -> [Artist] {
        persistentStore.objects(Artist.self, filteredBy: predicate)
    }

    func save(artists: [Artist]) -> AnyPublisher<Void, any Error> {
        persistentStore.save(artists)
    }
}
