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
import PromiseKit
import Alamofire

class UserNetworkRepositoryTests: XCTestCase {
  func testCheckUserExistsRequestParametersAreCorrect() {
    let networkService = StubNetworkService(response: EmptyResponse())
    let userRepository = UserNetworkRepository(networkService: networkService)
    userRepository.checkUserExists(withUsername: "User").done { _ in
      let expectedParameters: [String: AnyHashable] = ["method": "user.getInfo",
                                                       "api_key": Keys.LastFM.apiKey,
                                                       "user": "User",
                                                       "format": "json"]
      expect(networkService.parameters as? [String: AnyHashable]).to(equal(expectedParameters))
      expect(networkService.encoding).to(beAKindOf(URLEncoding.self))
      expect(networkService.headers).to(beNil())
    }.noError()
  }
}
