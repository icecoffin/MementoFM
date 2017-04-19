//
//  UserDataStorage.swift
//  LastFMNotifier
//
//  Created by Daniel on 09/12/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation

class UserDataStorage {
  private struct UserDefaultsKeys {
    static let username = "username"
    static let lastUpdateTimestamp = "lastUpdateTimestamp"
    static let didReceiveInitialCollection = "didReceiveInitialCollection"
  }

  private let userDefaults: UserDefaults

  init(userDefaults: UserDefaults = UserDefaults.standard) {
    self.userDefaults = userDefaults
  }

  deinit {
    print("deinit UserDataStorage")
  }

  var username: String? {
    get {
      return userDefaults.string(forKey: UserDefaultsKeys.username)
    }
    set {
      userDefaults.set(newValue, forKey: UserDefaultsKeys.username)
    }
  }

  var lastUpdateTimestamp: TimeInterval {
    get {
      return userDefaults.double(forKey: UserDefaultsKeys.lastUpdateTimestamp)
    }
    set {
      userDefaults.set(newValue, forKey: UserDefaultsKeys.lastUpdateTimestamp)
    }
  }

  var didReceiveInitialCollection: Bool {
    get {
      return userDefaults.bool(forKey: UserDefaultsKeys.didReceiveInitialCollection)
    }
    set {
      userDefaults.set(newValue, forKey: UserDefaultsKeys.didReceiveInitialCollection)
    }
  }

  func reset() {
    lastUpdateTimestamp = 0
    didReceiveInitialCollection = false
  }
}
