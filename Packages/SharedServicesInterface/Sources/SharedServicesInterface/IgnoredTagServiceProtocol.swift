import Foundation
import Combine
import TransientModels

public protocol IgnoredTagServiceProtocol: AnyObject {
    var defaultIgnoredTagNames: [String] { get }

    func ignoredTags() -> [IgnoredTag]
    func createDefaultIgnoredTags(withNames names: [String]) -> AnyPublisher<Void, Error>
    func updateIgnoredTags(_ ignoredTags: [IgnoredTag]) -> AnyPublisher<Void, Error>
}

public extension IgnoredTagServiceProtocol {
    var defaultIgnoredTagNames: [String] {
        return ["rock", "metal", "indie", "alternative", "seen live", "under 2000 listeners"]
    }

    func createDefaultIgnoredTags() -> AnyPublisher<Void, Error> {
        return createDefaultIgnoredTags(withNames: defaultIgnoredTagNames)
    }
}
