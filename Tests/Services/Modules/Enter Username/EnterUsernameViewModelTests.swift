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
  func testCanSubmitUsername() {
    let dependencies = Dependencies(userService: StubUserService())
    let viewModel = EnterUsernameViewModel(dependencies: dependencies)

    expect(viewModel.canSubmitUsername).to(beFalse())

    viewModel.updateUsername("username")
    dependencies.userService.username = "foo"
    expect(viewModel.canSubmitUsername).to(beTrue())

    dependencies.userService.username = "username"
    expect(viewModel.canSubmitUsername).to(beFalse())
  }

  func testCurrentUsernameText() {
    let dependencies = Dependencies(userService: StubUserService())
    let viewModel = EnterUsernameViewModel(dependencies: dependencies)

    expect(viewModel.currentUsernameText).to(equal(""))

    dependencies.userService.username = "username"
    expect(viewModel.currentUsernameText).to(equal(viewModel.currentUsernamePrefix + "username"))
  }

  func testSubmittingUsernameWithSuccess() {
    class StubEnterUsernameViewModelDelegate: EnterUsernameViewModelDelegate {
      var didCallEnterUsernameViewModelDidFinish = false
      func enterUsernameViewModelDidFinish(_ viewModel: EnterUsernameViewModel) {
        didCallEnterUsernameViewModelDidFinish = true
      }
    }

    let userService = StubUserService()
    let dependencies = Dependencies(userService: userService)
    let viewModel = EnterUsernameViewModel(dependencies: dependencies)

    var didStartRequest = false
    var didFinishRequest = false

    viewModel.onDidStartRequest = {
      didStartRequest = true
    }
    viewModel.onDidFinishRequest = {
      didFinishRequest = true
    }
    viewModel.onDidReceiveError = { _ in
      fail()
    }

    let delegate = StubEnterUsernameViewModelDelegate()
    viewModel.delegate = delegate

    viewModel.updateUsername("username")
    viewModel.submitUsername()

    expect(didStartRequest).toEventually(beTrue())
    expect(didFinishRequest).toEventually(beTrue())
    expect(delegate.didCallEnterUsernameViewModelDidFinish).toEventually(beTrue())
    expect(userService.usernameBeingChecked).toEventually(equal("username"))
    expect(userService.didCallClearUserData).toEventually(beTrue())
  }

  func testSubmittingUsernameWithError() {
    class StubEnterUsernameViewModelDelegate: EnterUsernameViewModelDelegate {
      func enterUsernameViewModelDidFinish(_ viewModel: EnterUsernameViewModel) {
        fail()
      }
    }

    let userService = StubUserService()
    userService.shouldFinishWithSuccess = false
    let dependencies = Dependencies(userService: userService)
    let viewModel = EnterUsernameViewModel(dependencies: dependencies)

    var didStartRequest = false
    var didFinishRequest = false
    var didReceiveError = false

    viewModel.onDidStartRequest = {
      didStartRequest = true
    }
    viewModel.onDidFinishRequest = {
      didFinishRequest = true
    }
    viewModel.onDidReceiveError = { _ in
      didReceiveError = true
    }

    let delegate = StubEnterUsernameViewModelDelegate()
    viewModel.delegate = delegate

    viewModel.updateUsername("username")
    viewModel.submitUsername()

    expect(didStartRequest).toEventually(beTrue())
    expect(didFinishRequest).toEventually(beTrue())
    expect(didReceiveError).toEventually(beTrue())
    expect(userService.usernameBeingChecked).to(equal("username"))
    expect(userService.didCallClearUserData).to(beFalse())
  }
}
