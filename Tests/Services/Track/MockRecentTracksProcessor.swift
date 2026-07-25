import Foundation
import Combine
@testable import MementoFM

final class MockRecentTracksProcessor: RecentTracksProcessing {
    var didCallProcess = false
    func process(tracks: [Track]) async throws {
        didCallProcess = true
    }
}
