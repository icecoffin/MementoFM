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
    func save(ignoredTags: [IgnoredTag]) async throws {
        saveCallCount += 1
        saveParameters = ignoredTags
    }

    private(set) var overwriteCallCount = 0
    private(set) var overwriteParameters: [IgnoredTag]?
    func overwrite(ignoredTags: [IgnoredTag]) async throws {
        overwriteCallCount += 1
        overwriteParameters = ignoredTags
    }
}
