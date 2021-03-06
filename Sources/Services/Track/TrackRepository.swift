//
//  TrackRepository.swift
//  MementoFM
//
//  Created by Daniel on 26/10/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

protocol TrackRepository: AnyObject {
    func getRecentTracksPage(withIndex index: Int,
                             for user: String,
                             from: TimeInterval,
                             limit: Int) -> Promise<RecentTracksPageResponse>
}

final class TrackNetworkRepository: TrackRepository {
    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func getRecentTracksPage(withIndex index: Int,
                             for user: String,
                             from: TimeInterval,
                             limit: Int) -> Promise<RecentTracksPageResponse> {
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
