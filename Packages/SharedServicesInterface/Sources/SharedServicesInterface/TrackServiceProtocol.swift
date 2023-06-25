import Foundation
import Combine
import TransientModels

public protocol TrackServiceProtocol: AnyObject {
    func getRecentTracks(for user: String, from: TimeInterval, limit: Int) -> AnyPublisher<RecentTracksPage, Error>
    func processTracks(_ tracks: [Track], using processor: RecentTracksProcessing) -> AnyPublisher<Void, Error>
}

public extension TrackServiceProtocol {
    func getRecentTracks(for user: String, from: TimeInterval) -> AnyPublisher<RecentTracksPage, Error> {
        return getRecentTracks(for: user, from: from, limit: 200)
    }
}
