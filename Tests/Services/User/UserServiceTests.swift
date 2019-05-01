//
//  UserServiceTests.swift
//  MementoFMTests
//
//  Created by Daniel on 02/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble
import PromiseKit

class UserServiceTests: XCTestCase {
  var userRepository: UserStubRepository!
  var userDataStorage: StubUserDataStorage!
  var persistentStore: StubPersistentStore!
  var userService: UserService!

  override func setUp() {
    super.setUp()

    userRepository = UserStubRepository()
    userDataStorage = StubUserDataStorage()
    persistentStore = StubPersistentStore()
    userService = UserService(persistentStore: persistentStore, repository: userRepository, userDataStorage: userDataStorage)
  }

  func test_username_readsFromUserDataStorage() {
    _ = userService.username

    expect(self.userDataStorage.didGetUsername) == true
  }

  func test_setUsername_writesToUserDataStorage() {
    userService.username = "test"

    expect(self.userDataStorage.didSetUsername) == true
  }

  func test_lastUpdateTimestamp_readsFromUserDataStorage() {
    _ = userService.lastUpdateTimestamp

    expect(self.userDataStorage.didGetLastUpdateTimestamp) == true
  }

  func test_setLastUpdateTimestamp_writesToUserDataStorage() {
    userService.lastUpdateTimestamp = 100

    expect(self.userDataStorage.didSetLastUpdateTimestamp) == true
  }

  func test_didReceiveInitialCollection_readsFromUserDataStorage() {
    _ = userService.didReceiveInitialCollection

    expect(self.userDataStorage.didGetDidReceiveInitialCollection) == true
  }

  func test_didReceiveInitialCollection_writesToUserDataStorage() {
    userService.didReceiveInitialCollection = true

    expect(self.userDataStorage.didSetDidReceiveInitialCollection) == true
  }

  func test_didFinishOnboarding_readsFromUserDataStorage() {
    _ = userService.didFinishOnboarding

    expect(self.userDataStorage.didGetDidFinishOnboarding) == true
  }

  func test_didFinishOnboarding_writesToUserDataStorage() {
    userService.didFinishOnboarding = true

    expect(self.userDataStorage.didSetDidFinishOnboarding) == true
  }

  func test_clearUserData_deletesArtists() {
    _ = userService.clearUserData()

    expect(self.persistentStore.deletedObjectsTypeNames).to(contain(String(describing: Artist.self)))
  }

  func test_clearUserData_deletesTags() {
    _ = userService.clearUserData()

    expect(self.persistentStore.deletedObjectsTypeNames).to(contain(String(describing: Tag.self)))
  }

  func test_clearUserData_resetsUserStorage() {
    _ = userService.clearUserData()

    expect(self.userDataStorage.didCallReset) == true
  }

  func test_checkingUserExists_callsUserRepository() {
    _ = userService.checkUserExists(withUsername: "test")

    expect(self.userRepository.checkedUsername) == "test"
  }
}
