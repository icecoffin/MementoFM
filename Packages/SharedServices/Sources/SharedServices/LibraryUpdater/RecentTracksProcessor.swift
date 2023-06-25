import Foundation
import Combine
import TransientModels
import PersistenceInterface
import SharedServicesInterface

final class RecentTracksProcessor: RecentTracksProcessing {
    func process(tracks: [Track], using persistentStore: PersistentStore) -> AnyPublisher<Void, Error> {
        var artistNamesWithPlayCounts = [Artist: Int]()

        for track in tracks {
            let artist = track.artist
            if let count = artistNamesWithPlayCounts[artist] {
                artistNamesWithPlayCounts[artist] = count + 1
            } else {
                artistNamesWithPlayCounts[artist] = 1
            }
        }

        let artists: [Artist] = artistNamesWithPlayCounts.map { artist, playcount in
            let updatedArtist = persistentStore.object(ofType: Artist.self, forPrimaryKey: artist.name) ?? artist
            return updatedArtist.updatingPlaycount(to: updatedArtist.playcount + playcount)
        }

        return persistentStore.save(artists)
    }
}
