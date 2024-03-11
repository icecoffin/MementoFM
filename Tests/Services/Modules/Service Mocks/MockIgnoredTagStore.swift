import Foundation
import Combine
@testable import MementoFM

final class MockIgnoredTagStore: IgnoredTagStore {
    private(set) var fetchAllCallCount = 0
    var customIgnoredTags: [IgnoredTag] = []
    func fetchAll() -> [IgnoredTag] {
        fetchAllCallCount += 1
        return customIgnoredTags
    }

    private(set) var saveCallCount = 0
    private(set) var saveParameters: [IgnoredTag]?
    func save(ignoredTags: [IgnoredTag]) -> AnyPublisher<Void, any Error> {
        saveCallCount += 1
        saveParameters = ignoredTags
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    private(set) var overwriteCallCount = 0
    private(set) var overwriteParameters: [IgnoredTag]?
    func overwrite(ignoredTags: [IgnoredTag]) -> AnyPublisher<Void, any Error> {
        overwriteCallCount += 1
        overwriteParameters = ignoredTags
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
