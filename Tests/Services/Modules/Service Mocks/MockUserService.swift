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

class MockUserService: UserServiceProtocol {
    var shouldFinishWithSuccess = true

    var username: String = ""
    var lastUpdateTimestamp: TimeInterval = 0
    var didReceiveInitialCollection: Bool = false
    var didFinishOnboarding: Bool = false

    var didCallClearUserData = false
    func clearUserData() -> AnyPublisher<Void, Error> {
        didCallClearUserData = true
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    var usernameBeingChecked = ""
    func checkUserExists(withUsername username: String) -> AnyPublisher<EmptyResponse, Error> {
        usernameBeingChecked = username
        if shouldFinishWithSuccess {
            return Just(EmptyResponse())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: NSError(domain: "MementoFM", code: 6, userInfo: nil))
                .eraseToAnyPublisher()
        }
    }
}
