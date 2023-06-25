import Foundation
import Combine

public protocol UserServiceProtocol: AnyObject {
    var username: String { get set }
    var lastUpdateTimestamp: TimeInterval { get set }
    var didReceiveInitialCollection: Bool { get set }
    var didFinishOnboarding: Bool { get set }

    func clearUserData() -> AnyPublisher<Void, Error>
    func checkUserExists(withUsername username: String) -> AnyPublisher<Void, Error>
}
