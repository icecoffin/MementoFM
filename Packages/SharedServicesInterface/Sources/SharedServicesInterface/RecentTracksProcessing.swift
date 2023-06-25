import Foundation
import Combine
import TransientModels
import PersistenceInterface

public protocol RecentTracksProcessing {
    func process(tracks: [Track], using persistentStore: PersistentStore) -> AnyPublisher<Void, Error>
}
