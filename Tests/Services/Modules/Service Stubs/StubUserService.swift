//
//  StubUserService.swift
//  MementoFM
//
//  Created by Daniel on 11/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import PromiseKit

class StubUserService: UserServiceProtocol {
  var shouldFinishWithSuccess = true

  var username: String = ""
  var lastUpdateTimestamp: TimeInterval = 0
  var didReceiveInitialCollection: Bool = false
  var didFinishOnboarding: Bool = false

  var didCallClearUserData = false
  func clearUserData() -> Promise<Void> {
    didCallClearUserData = true
    return .value(())
  }

  var usernameBeingChecked = ""
  func checkUserExists(withUsername username: String) -> Promise<EmptyResponse> {
    usernameBeingChecked = username
    if shouldFinishWithSuccess {
      return .value(EmptyResponse())
    } else {
      return Promise(error: NSError(domain: "MementoFM", code: 6, userInfo: nil))
    }
  }
}
