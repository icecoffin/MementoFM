//
//  UserRepository.swift
//  MementoFM
//
//  Created by Daniel on 26/10/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

protocol UserRepository: class {
  func checkUserExists(withUsername username: String) -> Promise<EmptyResponse>
}

class UserNetworkRepository: UserRepository {
  private let networkService: NetworkService

  init(networkService: NetworkService) {
    self.networkService = networkService
  }

  func checkUserExists(withUsername username: String) -> Promise<EmptyResponse> {
    let parameters: [String: Any] = ["method": "user.getInfo",
                                     "api_key": Keys.LastFM.apiKey,
                                     "user": username,
                                     "format": "json"]

    return networkService.performRequest(parameters: parameters)
  }
}
