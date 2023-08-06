import Foundation
import SharedServicesInterface

public struct IgnoredTagsDependencies: HasIgnoredTagService, HasArtistService {
    public let ignoredTagService: IgnoredTagServiceProtocol
    public let artistService: ArtistServiceProtocol

    public init(
        ignoredTagService: IgnoredTagServiceProtocol,
        artistService: ArtistServiceProtocol
    ) {
        self.ignoredTagService = ignoredTagService
        self.artistService = artistService
    }
}
