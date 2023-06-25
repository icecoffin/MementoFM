import Foundation
import Combine
import TransientModels
import PersistenceInterface

public protocol ArtistServiceProtocol: AnyObject {
    func getLibrary(for user: String, limit: Int) -> AnyPublisher<LibraryPage, Error>

    func saveArtists(_ artists: [Artist]) -> AnyPublisher<Void, Error>

    func artistsNeedingTagsUpdate() -> [Artist]
    func artistsWithIntersectingTopTags(for artist: Artist) -> [Artist]

    func updateArtist(_ artist: Artist, with tags: [Tag]) -> AnyPublisher<Artist, Error>

    func calculateTopTagsForAllArtists(ignoredTags: [IgnoredTag]) -> AnyPublisher<Void, Error>

    func calculateTopTags(for artist: Artist, ignoredTags: [IgnoredTag]) -> AnyPublisher<Void, Error>

    func artists(
        filteredUsing predicate: NSPredicate?,
        sortedBy sortDescriptors: [NSSortDescriptor]
    ) -> AnyPersistentMappedCollection<Artist>

    func getSimilarArtists(for artist: Artist, limit: Int) -> AnyPublisher<[Artist], Error>
}

public extension ArtistServiceProtocol {
    func getLibrary(for user: String) -> AnyPublisher<LibraryPage, Error> {
        return getLibrary(for: user, limit: 200)
    }

    func artists(sortedBy sortDescriptors: [NSSortDescriptor]) -> AnyPersistentMappedCollection<Artist> {
        return artists(filteredUsing: nil, sortedBy: sortDescriptors)
    }

    func getSimilarArtists(for artist: Artist) -> AnyPublisher<[Artist], Error> {
        return getSimilarArtists(for: artist, limit: 20)
    }
}
