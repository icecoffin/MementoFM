//
//  MockTagRepository.swift
//  MementoFM
//
//  Created by Daniel on 29/10/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import Combine
import TransientModels

final class MockTagRepository: TagRepository {
    var shouldFailWithError = false
    var tagProvider: ((String) -> [Tag])!

    func getTopTags(for artist: String) -> AnyPublisher<TopTagsResponse, Error> {
        if shouldFailWithError {
            return Fail(error: NSError(domain: "MementoFM", code: 1, userInfo: nil)).eraseToAnyPublisher()
        } else {
            let tags = tagProvider(artist)
            let topTagsList = TopTagsList(tags: tags)
            let response = TopTagsResponse(topTagsList: topTagsList)
            return Just(response)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
}
