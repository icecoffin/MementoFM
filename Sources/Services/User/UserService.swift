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
  private let userDataStorage: UserDataStorage

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

  init(realmService: RealmService, userDataStorage: UserDataStorage) {
    self.realmService = realmService
    self.userDataStorage = userDataStorage
  }

  func clearUserData() -> Promise<Void> {
    userDataStorage.reset()
    return realmService.write { realm in
      realm.delete(realm.objects(RealmArtist.self))
      realm.delete(realm.objects(RealmTag.self))
    }
  }
}
