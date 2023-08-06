//
//  MockUserService.swift
//  MementoFM
//
//  Created by Daniel on 11/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine
import SharedServicesInterface

public final class MockUserService: UserServiceProtocol {
    public init() { }

    public var shouldFinishWithSuccess = true

    public var username: String = ""
    public var lastUpdateTimestamp: TimeInterval = 0
    public var didReceiveInitialCollection: Bool = false
    public var didFinishOnboarding: Bool = false

    public var didCallClearUserData = false
    public func clearUserData() -> AnyPublisher<Void, Error> {
        didCallClearUserData = true
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    public var usernameBeingChecked = ""
    public func checkUserExists(withUsername username: String) -> AnyPublisher<Void, Error> {
        usernameBeingChecked = username
        if shouldFinishWithSuccess {
            return Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: NSError(domain: "MementoFM", code: 6, userInfo: nil))
                .eraseToAnyPublisher()
        }
    }
}
