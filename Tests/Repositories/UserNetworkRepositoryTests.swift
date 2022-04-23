//
//  UserNetworkRepositoryTests.swift
//  MementoFMTests
//
//  Created by Daniel on 07/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble
import Alamofire

final class UserNetworkRepositoryTests: XCTestCase {
    private var networkService: MockNetworkService!
    private var userRepository: UserNetworkRepository!

    override func setUp() {
        super.setUp()

        networkService = MockNetworkService()
        userRepository = UserNetworkRepository(networkService: networkService)
    }

    override func tearDown() {
        networkService = nil
        userRepository = nil

        super.tearDown()
    }

    func test_checkUserExists_callsNetworkServiceWithCorrectParameters() {
        networkService.customResponse = EmptyResponse()

        _ = userRepository.checkUserExists(withUsername: "User")

        let expectedParameters: [String: AnyHashable] = ["method": "user.getInfo",
                                                         "api_key": Keys.LastFM.apiKey,
                                                         "user": "User",
                                                         "format": "json"]

        let performRequestParameters = networkService.performRequestParameters
        expect(performRequestParameters?.parameters as? [String: AnyHashable]) == expectedParameters
        expect(performRequestParameters?.encoding).to(beAKindOf(URLEncoding.self))
        expect(performRequestParameters?.headers).to(beNil())
    }
}
