//
//  Dependencies.swift
//  MementoFM
//
//  Created by Daniel on 28/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

protocol HasArtistService {
  var artistService: ArtistService { get }
}

protocol HasUserService {
  var userService: UserService { get }
}

protocol HasTagService {
  var tagService: TagService { get }
}

protocol HasIgnoredTagService {
  var ignoredTagService: IgnoredTagService { get }
}

protocol HasLibraryUpdater {
  var libraryUpdater: LibraryUpdater { get }
}

struct AppDependency: HasArtistService, HasUserService, HasTagService, HasIgnoredTagService, HasLibraryUpdater {
  let artistService: ArtistService
  let userService: UserService
  let tagService: TagService
  let ignoredTagService: IgnoredTagService
  let trackService: TrackService

  let libraryUpdater: LibraryUpdater

  static var `default`: AppDependency {
    let realmService = RealmService(getRealm: {
      return RealmFactory.realm()
    })
    let userDataStorage = UserDataStorage()
    let networkService = LastFMNetworkService()

    let artistRepository = ArtistNetworkRepository(networkService: networkService)
    let artistService = ArtistService(realmService: realmService, repository: artistRepository)

    let userRepository = UserNetworkRepository(networkService: networkService)
    let userService = UserService(realmService: realmService, repository: userRepository, userDataStorage: userDataStorage)

    let tagRepository = TagNetworkRepository(networkService: networkService)
    let tagService = TagService(realmService: realmService, repository: tagRepository)

    let ignoredTagService = IgnoredTagService(realmService: realmService)

    let trackRepository = TrackNetworkRepository(networkService: networkService)
    let trackService = TrackService(realmService: realmService, repository: trackRepository)

    let libraryUpdater = LibraryUpdater(userService: userService, artistService: artistService, tagService: tagService,
                                        ignoredTagService: ignoredTagService, trackService: trackService,
                                        networkService: networkService)

    return AppDependency(artistService: artistService, userService: userService, tagService: tagService,
                         ignoredTagService: ignoredTagService, trackService: trackService, libraryUpdater: libraryUpdater)
  }
}
