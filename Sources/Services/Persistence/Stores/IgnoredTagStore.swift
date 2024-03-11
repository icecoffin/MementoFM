import Foundation
import Combine

// MARK: - IgnoredTagStore

protocol IgnoredTagStore {
    func fetchAll() -> [IgnoredTag]
    func save(ignoredTags: [IgnoredTag]) -> AnyPublisher<Void, Error>
    func overwrite(ignoredTags: [IgnoredTag]) -> AnyPublisher<Void, Error>
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

    func save(ignoredTags: [IgnoredTag]) -> AnyPublisher<Void, any Error> {
        persistentStore.save(ignoredTags)
    }

    func overwrite(ignoredTags: [IgnoredTag]) -> AnyPublisher<Void, Error> {
        persistentStore
            .deleteObjects(ofType: IgnoredTag.self)
            .flatMap { return self.persistentStore.save(ignoredTags) }
            .eraseToAnyPublisher()
    }
}
