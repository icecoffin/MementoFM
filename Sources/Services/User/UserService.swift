//
//  UserService.swift
//  MementoFM
//
//  Created by Daniel on 30/07/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

protocol UserServiceProtocol: AnyObject {
    var username: String { get set }
    var lastUpdateTimestamp: TimeInterval { get set }
    var didReceiveInitialCollection: Bool { get set }
    var didFinishOnboarding: Bool { get set }

    func clearUserData() -> Promise<Void>
    func checkUserExists(withUsername username: String) -> Promise<EmptyResponse>
}

final class UserService: UserServiceProtocol {
    private let persistentStore: PersistentStore
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

    init(persistentStore: PersistentStore, repository: UserRepository, userDataStorage: UserDataStoring) {
        self.persistentStore = persistentStore
        self.repository = repository
        self.userDataStorage = userDataStorage
    }

    func clearUserData() -> Promise<Void> {
        userDataStorage.reset()
        return when(fulfilled: [persistentStore.deleteObjects(ofType: Artist.self),
                                persistentStore.deleteObjects(ofType: Tag.self)])
    }

    func checkUserExists(withUsername username: String) -> Promise<EmptyResponse> {
        return repository.checkUserExists(withUsername: username)
    }
}
