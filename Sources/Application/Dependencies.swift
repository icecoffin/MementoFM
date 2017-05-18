//
//  Dependencies.swift
//  LastFMNotifier
//
//  Created by Daniel on 28/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

protocol HasRealmGateway {
  var realmGateway: RealmGateway { get }
}

protocol HasUserDataStorage {
  var userDataStorage: UserDataStorage { get }
}

protocol HasGeneralNetworkService {
  var generalNetworkService: GeneralNetworkService { get }
}

protocol HasArtistNetworkService {
  var artistNetworkService: ArtistNetworkService { get }
}

protocol HasLibraryNetworkService {
  var libraryNetworkService: LibraryNetworkService { get }
}

protocol HasUserNetworkService {
  var userNetworkService: UserNetworkService { get }
}

struct AppDependency: HasRealmGateway, HasUserDataStorage, HasGeneralNetworkService, HasArtistNetworkService,
                      HasLibraryNetworkService, HasUserNetworkService {
  let realmGateway: RealmGateway
  let userDataStorage: UserDataStorage
  private let networkService: NetworkService
  var generalNetworkService: GeneralNetworkService {
    return networkService
  }
  var artistNetworkService: ArtistNetworkService {
    return networkService
  }
  var libraryNetworkService: LibraryNetworkService {
    return networkService
  }
  var userNetworkService: UserNetworkService {
    return networkService
  }

  static var `default`: AppDependency {
    let realmGateway = RealmGateway(mainQueueRealm: RealmFactory.realm(), getCurrentQueueRealm: {
      return RealmFactory.realm()
    })
    let userDataStorage = UserDataStorage()
    let networkService = NetworkService()
    return AppDependency(realmGateway: realmGateway, userDataStorage: userDataStorage, networkService: networkService)
  }
}
