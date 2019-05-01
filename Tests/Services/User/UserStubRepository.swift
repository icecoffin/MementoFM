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
  var checkedUsername: String?
  func checkUserExists(withUsername username: String) -> Promise<EmptyResponse> {
    checkedUsername = username

    return .value(EmptyResponse())
  }
}
