//
//  Dependencies.swift
//  MementoFM
//
//  Created by Daniel on 28/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

protocol HasArtistService {
    var artistService: ArtistServiceProtocol { get }
}

protocol HasUserService {
    var userService: UserServiceProtocol { get }
}

protocol HasTagService {
    var tagService: TagServiceProtocol { get }
}

protocol HasIgnoredTagService {
    var ignoredTagService: IgnoredTagServiceProtocol { get }
}

protocol HasCountryService {
    var countryService: CountryServiceProtocol { get }
}

protocol HasLibraryUpdater {
    var libraryUpdater: LibraryUpdaterProtocol { get }
}

struct AppDependency: HasArtistService, HasUserService, HasTagService,
                      HasIgnoredTagService, HasCountryService, HasLibraryUpdater {
    let artistService: ArtistServiceProtocol
    let userService: UserServiceProtocol
    let tagService: TagServiceProtocol
    let ignoredTagService: IgnoredTagServiceProtocol
    let trackService: TrackServiceProtocol
    let countryService: CountryServiceProtocol

    let libraryUpdater: LibraryUpdaterProtocol

    static var `default`: AppDependency {
        let realmService = RealmService(getRealm: {
            return RealmFactory.realm()
        })
        let userDataStorage = UserDataStorage()
        let networkService = LastFMNetworkService()

        let artistStore = PersistentArtistStore(persistentStore: realmService)
        let ignoredTagStore = PersistentIgnoredTagStore(persistentStore: realmService)

        let artistRepository = ArtistNetworkRepository(networkService: networkService)
        let artistService = ArtistService(artistStore: artistStore, repository: artistRepository)

        let userRepository = UserNetworkRepository(networkService: networkService)
        let userService = UserService(artistStore: artistStore, repository: userRepository, userDataStorage: userDataStorage)

        let tagRepository = TagNetworkRepository(networkService: networkService)
        let tagService = TagService(artistStore: artistStore, repository: tagRepository)

        let ignoredTagService = IgnoredTagService(ignoredTagStore: ignoredTagStore)

        let trackRepository = TrackNetworkRepository(networkService: networkService)
        let trackService = TrackService(repository: trackRepository)
        let recentTracksProcessor = RecentTracksProcessor(artistStore: artistStore)

        let countryService = CountryService(artistStore: artistStore)

        let libraryUpdater = LibraryUpdater(
            userService: userService,
            artistService: artistService,
            tagService: tagService,
            ignoredTagService: ignoredTagService,
            trackService: trackService,
            recentTracksProcessor: recentTracksProcessor,
            countryService: countryService,
            networkService: networkService
        )

        return AppDependency(
            artistService: artistService,
            userService: userService,
            tagService: tagService,
            ignoredTagService: ignoredTagService,
            trackService: trackService,
            countryService: countryService,
            libraryUpdater: libraryUpdater
        )
    }
}
