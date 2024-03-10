import Foundation
import Combine
@testable import MementoFM

final class MockRecentTracksProcessor: RecentTracksProcessing {
    var didCallProcess = false

    func process(tracks: [Track]) -> AnyPublisher<Void, Error> {
        didCallProcess = true
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
