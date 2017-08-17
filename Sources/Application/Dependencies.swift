//
//  Dependencies.swift
//  MementoFM
//
//  Created by Daniel on 28/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

protocol HasRealmService {
  var realmService: RealmService { get }
}

protocol HasNetworkService {
  var networkService: LastFMNetworkService { get }
}

protocol HasUserDataStorage {
  var userDataStorage: UserDataStorage { get }
}

protocol HasArtistService {
  var artistService: ArtistService { get }
}

protocol HasUserService {
  var userService: UserService { get }
}

protocol HasTagService {
  var tagService: TagService { get }
}

struct AppDependency: HasUserDataStorage, HasNetworkService, HasRealmService, HasArtistService, HasUserService {
  let realmService: RealmService
  let userDataStorage: UserDataStorage
  let networkService: LastFMNetworkService
  let artistService: ArtistService
  let userService: UserService
  let tagService: TagService

  static var `default`: AppDependency {
    let realmService = RealmService.persistent
    let userDataStorage = UserDataStorage()
    let networkService = LastFMNetworkService()

    let artistService = ArtistService(realmService: realmService, networkService: networkService)
    let userService = UserService(realmService: realmService, networkService: networkService)
    let tagService = TagService(realmService: realmService)

    return AppDependency(realmService: realmService, userDataStorage: userDataStorage, networkService: networkService,
                         artistService: artistService, userService: userService, tagService: tagService)
  }
}
