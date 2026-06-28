//
//  UserRepository.swift
//  MementoFM
//
//  Created by Daniel on 26/10/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine

// MARK: - UserRepository

protocol UserRepository: AnyObject {
    func checkUserExists(withUsername username: String) async throws -> EmptyResponse
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

    func checkUserExists(withUsername username: String) async throws -> EmptyResponse {
        let parameters: [String: Any] = ["method": "user.getInfo",
                                         "api_key": Keys.LastFM.apiKey,
                                         "user": username,
                                         "format": "json"]

        return try await networkService.performRequest(parameters: parameters)
    }
}
