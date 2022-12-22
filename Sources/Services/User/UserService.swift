//
//  UserService.swift
//  MementoFM
//
//  Created by Daniel on 30/07/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine
import TransientModels

// MARK: - UserServiceProtocol

protocol UserServiceProtocol: AnyObject {
    var username: String { get set }
    var lastUpdateTimestamp: TimeInterval { get set }
    var didReceiveInitialCollection: Bool { get set }
    var didFinishOnboarding: Bool { get set }

    func clearUserData() -> AnyPublisher<Void, Error>
    func checkUserExists(withUsername username: String) -> AnyPublisher<EmptyResponse, Error>
}

// MARK: - UserService

final class UserService: UserServiceProtocol {
    // MARK: - Private properties

    private let persistentStore: PersistentStore
    private let repository: UserRepository
    private let userDataStorage: UserDataStoring

    // MARK: - Public properties

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

    // MARK: - Init

    init(persistentStore: PersistentStore, repository: UserRepository, userDataStorage: UserDataStoring) {
        self.persistentStore = persistentStore
        self.repository = repository
        self.userDataStorage = userDataStorage
    }

    // MARK: - Public methods

    func clearUserData() -> AnyPublisher<Void, Error> {
        userDataStorage.reset()
        return persistentStore.deleteObjects(ofType: Artist.self)
            .flatMap { _ in
                return self.persistentStore.deleteObjects(ofType: Tag.self)
            }
            .eraseToAnyPublisher()
    }

    func checkUserExists(withUsername username: String) -> AnyPublisher<EmptyResponse, Error> {
        return repository.checkUserExists(withUsername: username)
    }
}
