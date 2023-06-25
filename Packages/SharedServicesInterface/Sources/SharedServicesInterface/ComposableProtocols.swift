import Foundation

public protocol HasArtistService {
    var artistService: ArtistServiceProtocol { get }
}

public protocol HasUserService {
    var userService: UserServiceProtocol { get }
}

public protocol HasTagService {
    var tagService: TagServiceProtocol { get }
}

public protocol HasIgnoredTagService {
    var ignoredTagService: IgnoredTagServiceProtocol { get }
}

public protocol HasCountryService {
    var countryService: CountryServiceProtocol { get }
}

public protocol HasLibraryUpdater {
    var libraryUpdater: LibraryUpdaterProtocol { get }
}
