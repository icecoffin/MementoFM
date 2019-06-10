//
//  EnterUsernameViewModelTests.swift
//  MementoFMTests
//
//  Created by Daniel on 07/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble
import PromiseKit

private class Dependencies: EnterUsernameViewModel.Dependencies {
  let userService: UserServiceProtocol

  init(userService: UserServiceProtocol) {
    self.userService = userService
  }
}

class EnterUsernameViewModelTests: XCTestCase {
  func test_canSubmitUsername_returnsFalse_forEmptyUsername() {
    let dependencies = Dependencies(userService: StubUserService())
    let viewModel = EnterUsernameViewModel(dependencies: dependencies)

    expect(viewModel.canSubmitUsername).to(beFalse())
  }

  func test_canSubmitUsername_returnsTrue_forNewUsername() {
    let dependencies = Dependencies(userService: StubUserService())
    let viewModel = EnterUsernameViewModel(dependencies: dependencies)

    dependencies.userService.username = "foo"
    viewModel.updateUsername("username")

    expect(viewModel.canSubmitUsername).to(beTrue())
  }

  func test_canSubmitUsername_returnsFalse_forExistingUsername() {
    let dependencies = Dependencies(userService: StubUserService())
    let viewModel = EnterUsernameViewModel(dependencies: dependencies)

    viewModel.updateUsername("username")
    dependencies.userService.username = "username"

    expect(viewModel.canSubmitUsername).to(beFalse())
  }

  func test_currentUsername_returnsEmptyString_ifNoUsernameIsSet() {
    let dependencies = Dependencies(userService: StubUserService())
    let viewModel = EnterUsernameViewModel(dependencies: dependencies)

    expect(viewModel.currentUsernameText).to(equal(""))
  }

  func test_currentUsername_returnsCorrectValue_basedOnUserService() {
    let dependencies = Dependencies(userService: StubUserService())

    let viewModel = EnterUsernameViewModel(dependencies: dependencies)
    dependencies.userService.username = "username"

    expect(viewModel.currentUsernameText).to(equal(viewModel.currentUsernamePrefix + "username"))
  }

  func test_submitUsername_callsDidStartRequest() {
    let userService = StubUserService()
    let dependencies = Dependencies(userService: userService)
    let viewModel = EnterUsernameViewModel(dependencies: dependencies)

    var didStartRequest = false

    viewModel.didStartRequest = {
      didStartRequest = true
    }

    viewModel.updateUsername("username")
    viewModel.submitUsername()

    expect(didStartRequest).toEventually(beTrue())
  }

  func test_submitUsername_callsDidFinishRequest() {
    let userService = StubUserService()
    let dependencies = Dependencies(userService: userService)
    let viewModel = EnterUsernameViewModel(dependencies: dependencies)

    var didStartRequest = false

    viewModel.didStartRequest = {
      didStartRequest = true
    }
    viewModel.didReceiveError = { _ in
      // Test that didRecieveError is never called
      fail()
    }

    viewModel.updateUsername("username")
    viewModel.submitUsername()

    expect(didStartRequest).toEventually(beTrue())
  }

  func test_submitUsername_notifiesDelegateOnSuccess() {
    class StubEnterUsernameViewModelDelegate: EnterUsernameViewModelDelegate {
      var didCallEnterUsernameViewModelDidFinish = false
      func enterUsernameViewModelDidFinish(_ viewModel: EnterUsernameViewModel) {
        didCallEnterUsernameViewModelDidFinish = true
      }
    }

    let userService = StubUserService()
    let dependencies = Dependencies(userService: userService)
    let viewModel = EnterUsernameViewModel(dependencies: dependencies)

    let delegate = StubEnterUsernameViewModelDelegate()
    viewModel.delegate = delegate

    viewModel.updateUsername("username")
    viewModel.submitUsername()

    expect(delegate.didCallEnterUsernameViewModelDidFinish).toEventually(beTrue())
  }

  func test_submitUsername_checksThatUsernameExists() {
    let userService = StubUserService()
    let dependencies = Dependencies(userService: userService)
    let viewModel = EnterUsernameViewModel(dependencies: dependencies)

    viewModel.updateUsername("username")
    viewModel.submitUsername()

    expect(userService.usernameBeingChecked).toEventually(equal("username"))
  }

  func test_submitUsername_clearsUserDataOnSuccess() {
    let userService = StubUserService()
    let dependencies = Dependencies(userService: userService)
    let viewModel = EnterUsernameViewModel(dependencies: dependencies)

    viewModel.updateUsername("username")
    viewModel.submitUsername()

    expect(userService.didCallClearUserData).toEventually(beTrue())
  }

  func test_submitUsername_callsDidReceiveError() {
    class StubEnterUsernameViewModelDelegate: EnterUsernameViewModelDelegate {
      func enterUsernameViewModelDidFinish(_ viewModel: EnterUsernameViewModel) {
        // Test that delegate is not notified
        fail()
      }
    }

    let userService = StubUserService()
    userService.shouldFinishWithSuccess = false
    let dependencies = Dependencies(userService: userService)
    let viewModel = EnterUsernameViewModel(dependencies: dependencies)

    var didReceiveError = false

    viewModel.didReceiveError = { _ in
      didReceiveError = true
    }

    let delegate = StubEnterUsernameViewModelDelegate()
    viewModel.delegate = delegate

    viewModel.updateUsername("username")
    viewModel.submitUsername()

    expect(didReceiveError).toEventually(beTrue())
  }
}
