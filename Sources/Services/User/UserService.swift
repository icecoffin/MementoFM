//
//  UserService.swift
//  MementoFM
//
//  Created by Daniel on 30/07/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

class UserService {
  private let realmService: RealmService
  private let repository: UserRepository
  private let userDataStorage: UserDataStoring

  var username: String {
    get {
      return userDataStorage.username
    } set {
      userDataStorage.username = newValue
    }
  }

  var lastUpdateTimestamp: TimeInterval {
    get {
      return userDataStorage.lastUpdateTimestamp
    }
    set {
      userDataStorage.lastUpdateTimestamp = newValue
    }
  }

  var didReceiveInitialCollection: Bool {
    get {
      return userDataStorage.didReceiveInitialCollection
    }
    set {
      userDataStorage.didReceiveInitialCollection = newValue
    }
  }

  var didFinishOnboarding: Bool {
    get {
      return userDataStorage.didFinishOnboarding
    }
    set {
      userDataStorage.didFinishOnboarding = newValue
    }
  }

  init(realmService: RealmService, repository: UserRepository, userDataStorage: UserDataStoring) {
    self.realmService = realmService
    self.repository = repository
    self.userDataStorage = userDataStorage
  }

  func clearUserData() -> Promise<Void> {
    userDataStorage.reset()
    return when(fulfilled: [realmService.deleteObjects(ofType: Artist.self),
                            realmService.deleteObjects(ofType: Tag.self)])
  }

  func checkUserExists(withUsername username: String) -> Promise<EmptyResponse> {
    return repository.checkUserExists(withUsername: username)
  }
}
