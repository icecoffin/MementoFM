import Foundation
import Combine

// MARK: - ArtistStore

protocol ArtistStore {
    func artist(for id: String) -> Artist?
    func deleteAll() async throws
    func fetchAll(filteredBy predicate: NSPredicate?) -> [Artist]
    func save(artists: [Artist]) async throws
    func mappedCollection(
        filteredUsing predicate: NSPredicate?,
        sortedBy sortDescriptors: [NSSortDescriptor]
    ) -> AnyPersistentMappedCollection<Artist>
}

extension ArtistStore {
    func fetchAll() -> [Artist] {
        return fetchAll(filteredBy: nil)
    }

    func save(artist: Artist) async throws {
        try await save(artists: [artist])
    }
}

// MARK: - PersistentArtistStore

final class PersistentArtistStore: ArtistStore {
    private let persistentStore: PersistentStore

    init(persistentStore: PersistentStore) {
        self.persistentStore = persistentStore
    }

    func artist(for id: String) -> Artist? {
        return persistentStore.object(ofType: Artist.self, forPrimaryKey: id)
    }

    func deleteAll() async throws {
        try await persistentStore.deleteObjects(ofType: Artist.self)
    }

    func fetchAll(filteredBy predicate: NSPredicate?) -> [Artist] {
        persistentStore.objects(Artist.self, filteredBy: predicate)
    }

    func save(artists: [Artist]) async throws {
        try await persistentStore.save(artists)
    }

    func mappedCollection(
        filteredUsing predicate: NSPredicate?,
        sortedBy sortDescriptors: [NSSortDescriptor]
    ) -> AnyPersistentMappedCollection<Artist> {
        persistentStore.mappedCollection(filteredUsing: predicate, sortedBy: sortDescriptors)
    }
}
