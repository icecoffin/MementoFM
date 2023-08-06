//
//  TagRepository.swift
//  MementoFM
//
//  Created by Daniel on 26/10/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine
import NetworkingInterface
import Core

// MARK: - TagRepository

protocol TagRepository: AnyObject {
    func getTopTags(for artist: String) -> AnyPublisher<TopTagsResponse, Error>
}

// MARK: - TagNetworkRepository

final class TagNetworkRepository: TagRepository {
    // MARK: - Private properties

    private let networkService: NetworkService

    // MARK: - Init

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    // MARK: - Public methods

    func getTopTags(for artist: String) -> AnyPublisher<TopTagsResponse, Error> {
        let parameters: [String: Any] = [
            "method": "artist.gettoptags",
            "api_key": Keys.LastFM.apiKey,
            "artist": artist,
            "format": "json"
        ]

        return networkService.performRequest(parameters: parameters)
    }
}
