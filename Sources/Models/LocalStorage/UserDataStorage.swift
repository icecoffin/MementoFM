//
//  UserDataStorage.swift
//  MementoFM
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
  private struct InnerStorageKeys {
    static let username = "username"
    static let lastUpdateTimestamp = "lastUpdateTimestamp"
    static let didFinishOnboarding = "didFinishOnboarding"
    static let didReceiveInitialCollection = "didReceiveInitialCollection"
  }

  private let innerStorage: UserDataInnerStorage

  init(innerStorage: UserDataInnerStorage = UserDefaults.standard) {
    self.innerStorage = innerStorage
  }

  var username: String {
    get {
      return innerStorage.string(forKey: InnerStorageKeys.username) ?? ""
    }
    set {
      innerStorage.set(newValue, forKey: InnerStorageKeys.username)
    }
  }

  var lastUpdateTimestamp: TimeInterval {
    get {
      return innerStorage.double(forKey: InnerStorageKeys.lastUpdateTimestamp)
    }
    set {
      innerStorage.set(newValue, forKey: InnerStorageKeys.lastUpdateTimestamp)
    }
  }

  var didFinishOnboarding: Bool {
    get {
      return innerStorage.bool(forKey: InnerStorageKeys.didFinishOnboarding)
    }
    set {
      innerStorage.set(newValue, forKey: InnerStorageKeys.didFinishOnboarding)
    }
  }

  var didReceiveInitialCollection: Bool {
    get {
      return innerStorage.bool(forKey: InnerStorageKeys.didReceiveInitialCollection)
    }
    set {
      innerStorage.set(newValue, forKey: InnerStorageKeys.didReceiveInitialCollection)
    }
  }

  func reset() {
    lastUpdateTimestamp = 0
    didReceiveInitialCollection = false
  }
}
