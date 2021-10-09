//
//  UserDataStorage.swift
//  MementoFM
//
//  Created by Daniel on 09/12/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation

// MARK: - UserDataStoring

protocol UserDataStoring: AnyObject {
    var username: String { get set }
    var lastUpdateTimestamp: TimeInterval { get set }
    var didFinishOnboarding: Bool { get set }
    var didReceiveInitialCollection: Bool { get set}

    func reset()
}

// MARK: - UserDataStorage

final class UserDataStorage: UserDataStoring {
    private struct UserDefaultsKeys {
        static let username = "username"
        static let lastUpdateTimestamp = "lastUpdateTimestamp"
        static let didFinishOnboarding = "didFinishOnboarding"
        static let didReceiveInitialCollection = "didReceiveInitialCollection"
    }

    // MARK: - Private properties

    private let userDefaults: UserDefaults

    // MARK: - Public properties

    var username: String {
        get {
            return userDefaults.string(forKey: UserDefaultsKeys.username) ?? ""
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

    var didFinishOnboarding: Bool {
        get {
            return userDefaults.bool(forKey: UserDefaultsKeys.didFinishOnboarding)
        }
        set {
            userDefaults.set(newValue, forKey: UserDefaultsKeys.didFinishOnboarding)
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

    // MARK: - Init

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - Public methods

    func reset() {
        lastUpdateTimestamp = 0
        didReceiveInitialCollection = false
    }
}
