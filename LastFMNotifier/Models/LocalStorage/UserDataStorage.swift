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
  }

  private let userDefaults: UserDefaults

  init(userDefaults: UserDefaults = UserDefaults.standard) {
    self.userDefaults = userDefaults
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
}
