//
//  UserStubRepository.swift
//  MementoFM
//
//  Created by Daniel on 02/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import PromiseKit

class UserStubRepository: UserRepository {
  let shouldFinishWithSuccess: Bool

  init(shouldFinishWithSuccess: Bool) {
    self.shouldFinishWithSuccess = shouldFinishWithSuccess
  }

  func checkUserExists(withUsername username: String) -> Promise<EmptyResponse> {
    if shouldFinishWithSuccess {
      return .value(EmptyResponse())
    } else {
      let error = NSError(domain: "MementoFM", code: 6, userInfo: nil)
      return Promise(error: error)
    }
  }
}
