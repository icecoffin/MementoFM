//
//  UserServiceTests.swift
//  MementoFMTests
//
//  Created by Daniel on 02/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM

final class UserServiceTests: XCTestCase {
    private var userRepository: MockUserRepository!
    private var userDataStorage: MockUserDataStorage!
    private var artistStore: MockArtistStore!
    private var userService: UserService!

    override func setUp() {
        super.setUp()

        userRepository = MockUserRepository()
        userDataStorage = MockUserDataStorage()
        artistStore = MockArtistStore()
        userService = UserService(artistStore: artistStore, repository: userRepository, userDataStorage: userDataStorage)
    }

    override func tearDown() {
        userRepository = nil
        userDataStorage = nil
        artistStore = nil
        userService = nil

        super.tearDown()
    }

    func test_username_readsFromUserDataStorage() {
        _ = userService.username

        XCTAssertTrue(userDataStorage.didGetUsername)
    }

    func test_setUsername_writesToUserDataStorage() {
        userService.username = "test"

        XCTAssertTrue(userDataStorage.didSetUsername)
    }

    func test_lastUpdateTimestamp_readsFromUserDataStorage() {
        _ = userService.lastUpdateTimestamp

        XCTAssertTrue(userDataStorage.didGetLastUpdateTimestamp)
    }

    func test_setLastUpdateTimestamp_writesToUserDataStorage() {
        userService.lastUpdateTimestamp = 100

        XCTAssertTrue(userDataStorage.didSetLastUpdateTimestamp)
    }

    func test_didReceiveInitialCollection_readsFromUserDataStorage() {
        _ = userService.didReceiveInitialCollection

        XCTAssertTrue(userDataStorage.didGetDidReceiveInitialCollection)
    }

    func test_didReceiveInitialCollection_writesToUserDataStorage() {
        userService.didReceiveInitialCollection = true

        XCTAssertTrue(userDataStorage.didSetDidReceiveInitialCollection)
    }

    func test_didFinishOnboarding_readsFromUserDataStorage() {
        _ = userService.didFinishOnboarding

        XCTAssertTrue(userDataStorage.didGetDidFinishOnboarding)
    }

    func test_didFinishOnboarding_writesToUserDataStorage() {
        userService.didFinishOnboarding = true

        XCTAssertTrue(userDataStorage.didSetDidFinishOnboarding)
    }

    func test_clearUserData_deletesArtists() {
        _ = userService.clearUserData()
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })

        XCTAssertEqual(artistStore.deleteAllCallCount, 1)
    }

    func test_clearUserData_resetsUserStorage() {
        _ = userService.clearUserData()

        XCTAssertTrue(userDataStorage.didCallReset)
    }

    func test_checkingUserExists_callsUserRepository() {
        _ = userService.checkUserExists(withUsername: "test")

        XCTAssertEqual(userRepository.checkedUsername, "test")
    }
}
