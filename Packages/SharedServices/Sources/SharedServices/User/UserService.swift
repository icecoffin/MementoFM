//
//  UserService.swift
//  MementoFM
//
//  Created by Daniel on 30/07/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine
import Networking
import TransientModels
import PersistenceInterface
import SharedServicesInterface

public final class UserService: UserServiceProtocol {
    // MARK: - Private properties

    private let persistentStore: PersistentStore
    private let repository: UserRepository
    private let userDataStorage: UserDataStoring

    // MARK: - Public properties

    public var username: String {
        get {
            return userDataStorage.username
        } set {
            userDataStorage.username = newValue
        }
    }

    public var lastUpdateTimestamp: TimeInterval {
        get {
            return userDataStorage.lastUpdateTimestamp
        }
        set {
            userDataStorage.lastUpdateTimestamp = newValue
        }
    }

    public var didReceiveInitialCollection: Bool {
        get {
            return userDataStorage.didReceiveInitialCollection
        }
        set {
            userDataStorage.didReceiveInitialCollection = newValue
        }
    }

    public var didFinishOnboarding: Bool {
        get {
            return userDataStorage.didFinishOnboarding
        }
        set {
            userDataStorage.didFinishOnboarding = newValue
        }
    }

    // MARK: - Init

    public convenience init(
        persistentStore: PersistentStore,
        networkService: NetworkService
    ) {
        self.init(
            persistentStore: persistentStore,
            repository: UserNetworkRepository(networkService: networkService),
            userDataStorage: UserDataStorage()
        )
    }

    init(
        persistentStore: PersistentStore,
        repository: UserRepository,
        userDataStorage: UserDataStoring
    ) {
        self.persistentStore = persistentStore
        self.repository = repository
        self.userDataStorage = userDataStorage
    }

    // MARK: - Public methods

    public func clearUserData() -> AnyPublisher<Void, Error> {
        userDataStorage.reset()
        return persistentStore.deleteObjects(ofType: Artist.self)
            .flatMap { _ in
                return self.persistentStore.deleteObjects(ofType: Tag.self)
            }
            .eraseToAnyPublisher()
    }

    public func checkUserExists(withUsername username: String) -> AnyPublisher<Void, Error> {
        return repository
            .checkUserExists(withUsername: username)
            .map { _ in }
            .eraseToAnyPublisher()
    }
}
