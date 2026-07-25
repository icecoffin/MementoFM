//
//  MockUserService.swift
//  MementoFM
//
//  Created by Daniel on 11/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import Combine

final class MockUserService: UserServiceProtocol {
    var shouldFinishWithSuccess = true

    var username: String = ""
    var lastUpdateTimestamp: TimeInterval = 0
    var didReceiveInitialCollection: Bool = false
    var didFinishOnboarding: Bool = false

    var didCallClearUserData = false
    func clearUserData() async throws {
        didCallClearUserData = true
    }

    var usernameBeingChecked = ""
    func checkUserExists(withUsername username: String) async throws -> EmptyResponse {
        usernameBeingChecked = username
        if shouldFinishWithSuccess {
            return EmptyResponse()
        } else {
            throw NSError(domain: "MementoFM", code: 6, userInfo: nil)
        }
    }
}
