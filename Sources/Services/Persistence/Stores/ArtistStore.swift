import Foundation
import Combine

// MARK: - ArtistStore

protocol ArtistStore {
    func artist(for name: String) -> Artist?
    func deleteAll() -> AnyPublisher<Void, Error>
    func fetchAll(filteredBy predicate: NSPredicate?) -> [Artist]
    func save(artists: [Artist]) -> AnyPublisher<Void, Error>
    func mappedCollection(
        filteredUsing predicate: NSPredicate?,
        sortedBy sortDescriptors: [NSSortDescriptor]
    ) -> AnyPersistentMappedCollection<Artist>
}

extension ArtistStore {
    func fetchAll() -> [Artist] {
        return fetchAll(filteredBy: nil)
    }

    func save(artist: Artist) -> AnyPublisher<Void, Error> {
        return save(artists: [artist])
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

    func mappedCollection(
        filteredUsing predicate: NSPredicate?,
        sortedBy sortDescriptors: [NSSortDescriptor]
    ) -> AnyPersistentMappedCollection<Artist> {
        persistentStore.mappedCollection(filteredUsing: predicate, sortedBy: sortDescriptors)
    }
}
