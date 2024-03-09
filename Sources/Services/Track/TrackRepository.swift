//
//  TrackRepository.swift
//  MementoFM
//
//  Created by Daniel on 26/10/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine

// MARK: - TrackRepository

protocol TrackRepository: AnyObject {
    func getRecentTracksPage(
        withIndex index: Int,
        for user: String,
        from: TimeInterval,
        limit: Int
    ) -> AnyPublisher<RecentTracksPageResponse, Error>
}

// MARK: - TrackNetworkRepository

final class TrackNetworkRepository: TrackRepository {
    // MARK: - Private properties

    private let networkService: NetworkService

    // MARK: - Init

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    // MARK: - Public methods

    func getRecentTracksPage(
        withIndex index: Int,
        for user: String,
        from: TimeInterval,
        limit: Int
    ) -> AnyPublisher<RecentTracksPageResponse, Error> {
        let parameters: [String: Any] = ["method": "user.getrecenttracks",
                                         "api_key": Keys.LastFM.apiKey,
                                         "user": user,
                                         "from": from,
                                         "extended": 1,
                                         "format": "json",
                                         "page": index,
                                         "limit": limit]

        return networkService.performRequest(parameters: parameters)
    }
}
