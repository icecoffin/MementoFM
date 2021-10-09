//
//  UserRepository.swift
//  MementoFM
//
//  Created by Daniel on 26/10/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

// MARK: - UserRepository

protocol UserRepository: AnyObject {
    func checkUserExists(withUsername username: String) -> Promise<EmptyResponse>
}

// MARK: - UserNetworkRepository

final class UserNetworkRepository: UserRepository {
    // MARK: - Private properties

    private let networkService: NetworkService

    // MARK: - Init

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    // MARK: - Public methods

    func checkUserExists(withUsername username: String) -> Promise<EmptyResponse> {
        let parameters: [String: Any] = ["method": "user.getInfo",
                                         "api_key": Keys.LastFM.apiKey,
                                         "user": username,
                                         "format": "json"]

        return networkService.performRequest(parameters: parameters)
    }
}
