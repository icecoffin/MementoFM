//
//  TagRepository.swift
//  MementoFM
//
//  Created by Daniel on 26/10/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

protocol TagRepository: class {
    func getTopTags(for artist: String) -> Promise<TopTagsResponse>
}

final class TagNetworkRepository: TagRepository {
    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func getTopTags(for artist: String) -> Promise<TopTagsResponse> {
        let parameters: [String: Any] = ["method": "artist.gettoptags",
                                         "api_key": Keys.LastFM.apiKey,
                                         "artist": artist,
                                         "format": "json"]

        return networkService.performRequest(parameters: parameters)
    }
}
