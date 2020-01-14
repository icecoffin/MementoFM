//
//  StubUserDataStorage.swift
//  MementoFM
//
//  Created by Daniel on 03/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM

class StubUserDataStorage: UserDataStoring {
    private var _username: String = ""
    var didGetUsername = false
    var didSetUsername = false

    var username: String {
        get {
            didGetUsername = true
            return _username
        }
        set {
            didSetUsername = true
            _username = newValue
        }
    }

    private var _lastUpdateTimestamp: TimeInterval = 0
    var didGetLastUpdateTimestamp = false
    var didSetLastUpdateTimestamp = false

    var lastUpdateTimestamp: TimeInterval {
        get {
            didGetLastUpdateTimestamp = true
            return _lastUpdateTimestamp
        }
        set {
            didSetLastUpdateTimestamp = true
            _lastUpdateTimestamp = newValue
        }
    }

    private var _didFinishOnboarding: Bool = false
    var didGetDidFinishOnboarding = false
    var didSetDidFinishOnboarding = false

    var didFinishOnboarding: Bool {
        get {
            didGetDidFinishOnboarding = true
            return _didFinishOnboarding
        }
        set {
            didSetDidFinishOnboarding = true
            _didFinishOnboarding = newValue
        }
    }

    private var _didReceiveInitialCollection: Bool = false
    var didGetDidReceiveInitialCollection = false
    var didSetDidReceiveInitialCollection = false

    var didReceiveInitialCollection: Bool {
        get {
            didGetDidReceiveInitialCollection = true
            return _didReceiveInitialCollection
        }
        set {
            didSetDidReceiveInitialCollection = true
            _didReceiveInitialCollection = newValue
        }
    }

    var didCallReset = false

    func reset() {
        didCallReset = true
    }
}
