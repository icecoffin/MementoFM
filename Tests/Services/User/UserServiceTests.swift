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
  var realmService: RealmService!

  override func setUp() {
    super.setUp()

    realmService = RealmService(getRealm: {
      return RealmFactory.inMemoryRealm()
    })
  }

  override func tearDown() {
    realmService = nil
    super.tearDown()
  }

  func testUsername() {
    let userRepository = UserStubRepository(shouldFinishWithSuccess: true)
    let userDataStorage = StubUserDataStorage()
    let userService = UserService(realmService: realmService, repository: userRepository, userDataStorage: userDataStorage)

    userService.username = "test"
    expect(userDataStorage.didSetUsername).to(beTrue())
    _ = userService.username
    expect(userDataStorage.didGetUsername).to(beTrue())
  }

  func testLastUpdateTimestamp() {
    let userRepository = UserStubRepository(shouldFinishWithSuccess: true)
    let userDataStorage = StubUserDataStorage()
    let userService = UserService(realmService: realmService, repository: userRepository, userDataStorage: userDataStorage)

    userService.lastUpdateTimestamp = 100
    expect(userDataStorage.didSetLastUpdateTimestamp).to(beTrue())
    _ = userService.lastUpdateTimestamp
    expect(userDataStorage.didGetLastUpdateTimestamp).to(beTrue())
  }

  func testDidReceiveInitialCollection() {
    let userRepository = UserStubRepository(shouldFinishWithSuccess: true)
    let userDataStorage = StubUserDataStorage()
    let userService = UserService(realmService: realmService, repository: userRepository, userDataStorage: userDataStorage)

    userService.didReceiveInitialCollection = true
    expect(userDataStorage.didSetDidReceiveInitialCollection).to(beTrue())
    _ = userService.didReceiveInitialCollection
    expect(userDataStorage.didGetDidReceiveInitialCollection).to(beTrue())
  }

  func testDidFinishOnboarding() {
    let userRepository = UserStubRepository(shouldFinishWithSuccess: true)
    let userDataStorage = StubUserDataStorage()
    let userService = UserService(realmService: realmService, repository: userRepository, userDataStorage: userDataStorage)

    userService.didFinishOnboarding = true
    expect(userDataStorage.didSetDidFinishOnboarding).to(beTrue())
    _ = userService.didFinishOnboarding
    expect(userDataStorage.didGetDidFinishOnboarding).to(beTrue())
  }

  func testClearingUserData() {
    let userRepository = UserStubRepository(shouldFinishWithSuccess: true)
    let userDataStorage = StubUserDataStorage()
    let userService = UserService(realmService: realmService, repository: userRepository, userDataStorage: userDataStorage)

    waitUntil { done in
      let artists: [Artist] = ModelFactory.generateArtists(inAmount: 5).map { artist in
        let tags = ModelFactory.generateTags(inAmount: 5, for: artist.name)
        return artist.updatingTags(to: tags, needsTagsUpdate: artist.needsTagsUpdate)
      }
      firstly {
        self.realmService.save(artists)
      }.then {
        userService.clearUserData()
      }.then { _ -> Void in
        expect(self.realmService.hasObjects(ofType: Artist.self)).to(beFalse())
        expect(self.realmService.hasObjects(ofType: Tag.self)).to(beFalse())
        expect(userDataStorage.didCallReset).to(beTrue())
        done()
      }.noError()
    }
  }

  func testCheckingUserExistsWithSuccess() {
    let userRepository = UserStubRepository(shouldFinishWithSuccess: true)
    let userDataStorage = StubUserDataStorage()
    let userService = UserService(realmService: realmService, repository: userRepository, userDataStorage: userDataStorage)

    waitUntil { done in
      userService.checkUserExists(withUsername: "test").then { _ in
        done()
      }.catch { _ in
        fail()
      }
    }
  }

  func testCheckingUserExistsWithFailure() {
    let userRepository = UserStubRepository(shouldFinishWithSuccess: false)
    let userDataStorage = StubUserDataStorage()
    let userService = UserService(realmService: realmService, repository: userRepository, userDataStorage: userDataStorage)

    waitUntil { done in
      userService.checkUserExists(withUsername: "test").then { _ in
        fail()
      }.catch { _ in
        done()
      }
    }
  }
}
