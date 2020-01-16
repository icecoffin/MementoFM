//
//  MockTagRepository.swift
//  MementoFM
//
//  Created by Daniel on 29/10/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import PromiseKit

class MockTagRepository: TagRepository {
    var shouldFailWithError = false
    var tagProvider: ((String) -> [Tag])!

    func getTopTags(for artist: String) -> Promise<TopTagsResponse> {
        if shouldFailWithError {
            return Promise(error: NSError(domain: "MementoFM", code: 1, userInfo: nil))
        } else {
            let tags = tagProvider(artist)
            let topTagsList = TopTagsList(tags: tags)
            let response = TopTagsResponse(topTagsList: topTagsList)
            return .value(response)
        }
    }
}
