import Foundation
import Combine

// MARK: - IgnoredTagStore

protocol IgnoredTagStore {
    func fetchAll() -> [IgnoredTag]
    func save(ignoredTags: [IgnoredTag]) async throws
    func overwrite(ignoredTags: [IgnoredTag]) async throws
}

// MARK: - PersistentIgnoredTagStore

final class PersistentIgnoredTagStore: IgnoredTagStore {
    private let persistentStore: PersistentStore

    init(persistentStore: PersistentStore) {
        self.persistentStore = persistentStore
    }

    func fetchAll() -> [IgnoredTag] {
        persistentStore.objects(IgnoredTag.self)
    }

    func save(ignoredTags: [IgnoredTag]) async throws {
        try await persistentStore.save(ignoredTags)
    }

    func overwrite(ignoredTags: [IgnoredTag]) async throws {
        try await persistentStore.deleteObjects(ofType: IgnoredTag.self)
        try await persistentStore.save(ignoredTags)
    }
}
