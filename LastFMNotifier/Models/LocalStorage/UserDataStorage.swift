//
//  UserDataStorage.swift
//  LastFMNotifier
//
//  Created by Daniel on 09/12/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation

protocol UserDataInnerStorage: class {
  func set(_ value: Any?, forKey key: String)

  func string(forKey key: String) -> String?
  func double(forKey key: String) -> Double
  func bool(forKey key: String) -> Bool
}

extension UserDefaults: UserDataInnerStorage { }

class UserDataStorage {
  private struct UserDefaultsKeys {
    static let username = "username"
    static let lastUpdateTimestamp = "lastUpdateTimestamp"
    static let didReceiveInitialCollection = "didReceiveInitialCollection"
  }

  private let innerStorage: UserDataInnerStorage

  init(innerStorage: UserDataInnerStorage = UserDefaults.standard) {
    self.innerStorage = innerStorage
  }

  var username: String? {
    get {
      return innerStorage.string(forKey: UserDefaultsKeys.username)
    }
    set {
      innerStorage.set(newValue, forKey: UserDefaultsKeys.username)
    }
  }

  var lastUpdateTimestamp: TimeInterval {
    get {
      return innerStorage.double(forKey: UserDefaultsKeys.lastUpdateTimestamp)
    }
    set {
      innerStorage.set(newValue, forKey: UserDefaultsKeys.lastUpdateTimestamp)
    }
  }

  var didReceiveInitialCollection: Bool {
    get {
      return innerStorage.bool(forKey: UserDefaultsKeys.didReceiveInitialCollection)
    }
    set {
      innerStorage.set(newValue, forKey: UserDefaultsKeys.didReceiveInitialCollection)
    }
  }

  func reset() {
    lastUpdateTimestamp = 0
    didReceiveInitialCollection = false
  }
}
