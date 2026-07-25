//
//  MockUserRepository.swift
//  MementoFM
//
//  Created by Daniel on 02/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import Combine

final class MockUserRepository: UserRepository {
    var checkedUsername: String?
    func checkUserExists(withUsername username: String) async throws -> EmptyResponse {
        checkedUsername = username
        return EmptyResponse()
    }
}
