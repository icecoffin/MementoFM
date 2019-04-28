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

protocol HasLibraryUpdater {
  var libraryUpdater: LibraryUpdaterProtocol { get }
}

struct AppDependency: HasArtistService, HasUserService, HasTagService, HasIgnoredTagService, HasLibraryUpdater {
  let artistService: ArtistServiceProtocol
  let userService: UserServiceProtocol
  let tagService: TagServiceProtocol
  let ignoredTagService: IgnoredTagServiceProtocol
  let trackService: TrackServiceProtocol

  let libraryUpdater: LibraryUpdaterProtocol

  static var `default`: AppDependency {
    let realmService = RealmService(getRealm: {
      return RealmFactory.realm()
    })
    let userDataStorage = UserDataStorage()
    let networkService = LastFMNetworkService()

    let artistRepository = ArtistNetworkRepository(networkService: networkService)
    let artistService = ArtistService(persistentStore: realmService, repository: artistRepository)

    let userRepository = UserNetworkRepository(networkService: networkService)
    let userService = UserService(persistentStore: realmService, repository: userRepository, userDataStorage: userDataStorage)

    let tagRepository = TagNetworkRepository(networkService: networkService)
    let tagService = TagService(persistentStore: realmService, repository: tagRepository)

    let ignoredTagService = IgnoredTagService(persistentStore: realmService)

    let trackRepository = TrackNetworkRepository(networkService: networkService)
    let trackService = TrackService(persistentStore: realmService, repository: trackRepository)

    let libraryUpdater = LibraryUpdater(userService: userService, artistService: artistService, tagService: tagService,
                                        ignoredTagService: ignoredTagService, trackService: trackService,
                                        networkService: networkService)

    return AppDependency(artistService: artistService, userService: userService, tagService: tagService,
                         ignoredTagService: ignoredTagService, trackService: trackService, libraryUpdater: libraryUpdater)
  }
}
