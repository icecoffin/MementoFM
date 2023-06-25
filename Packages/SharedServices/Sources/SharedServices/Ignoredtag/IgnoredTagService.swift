import Foundation
import Combine
import SharedServicesInterface
import TransientModels
import PersistenceInterface
import Persistence

public final class IgnoredTagService: IgnoredTagServiceProtocol {
    // MARK: - Private properties

    private let persistentStore: PersistentStore

    // MARK: - Init

    public init(persistentStore: PersistentStore) {
        self.persistentStore = persistentStore
    }

    // MARK: - Public methods

    public func ignoredTags() -> [IgnoredTag] {
        return persistentStore.objects(IgnoredTag.self)
    }

    public func createDefaultIgnoredTags(withNames names: [String]) -> AnyPublisher<Void, Error> {
        let ignoredTags = names.map { name in
            return IgnoredTag(uuid: UUID().uuidString, name: name)
        }
        return persistentStore.save(ignoredTags)
    }

    public func updateIgnoredTags(_ ignoredTags: [IgnoredTag]) -> AnyPublisher<Void, Error> {
        return persistentStore
            .deleteObjects(ofType: IgnoredTag.self)
            .flatMap {
                return self.persistentStore.save(ignoredTags)
            }
            .eraseToAnyPublisher()
    }
}
